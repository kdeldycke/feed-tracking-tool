require 'feed_tools'


# Monkey patch feed tool.
# Use case mixed UTF-8 chars and html entities: <description>Téléchargements et Multim&#233;dia</description>
# TODO: send test case to Python Universal Feed Parser and patch to Feed Tool project.
module FeedTools::HtmlHelper
  class << self

    # Force UTF-8 conversion of HTML entities with number lower than 256.
    # Based on CGI::unescapeHTML method.
    def convert_html_entities_to_unicode(string)
      string.gsub(/&(.*?);/n) do
        $KCODE = "UTF8"
        match = $1.dup
        case match
        when /\A#0*(\d+)\z/n       then
          if Integer($1) < 256
            [Integer($1)].pack("U")
          else
            "&##{$1};"
          end
        when /\A#x([0-9a-f]+)\z/ni then
          if $1.hex < 256
            [$1.hex].pack("U")
          else
            "&#x#{$1};"
          end
        else
          "&#{match};"
        end
      end
    end

    # Patch unescape_entities() method
    alias_method :unescape_entities_orig, :unescape_entities
    def unescape_entities(html)
      return unescape_entities_orig(convert_html_entities_to_unicode(html))
    end

  end
end