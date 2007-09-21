require "feedalizer"

module FeedalizerTools


  # Method to transform a static page to a RSS 1.0 feed
  def self.get_feed_from_static_page(url)
    feed_xml = nil

    if url.size > 0  # TODO: perform other validation stuff
      # The date of the feed / article is when we fetch the page
      date = Time.now

      # Fetch static page
      page = Feedalizer.new(url)

      # Set feed attributes using static page attributes
      page.feed.about       = url
      page.feed.title       = self.getHtmlTagContent(page, "title")
      page.feed.description = self.getHtmlTagContent(page, "description")

      # Make content of the first <body> tag the only feed item
      page.scrape_items("body", limit = 1) do |rss_item, html_element|
        rss_item.link  = url
        rss_item.date  = date
        rss_item.title = page.feed.title  # + " | " + rss_item.date.strftime(DATE_FORMAT) XXX Not a good idea to add date in title
        rss_item.description = html_element.inner_html  # TODO: sanitize html content ?
      end

      # Output RSS 1.0 XML content
      feed_xml = page.output
    end

    return feed_xml
  end


  # Tiny method to get the inner content of the first html tag given as parameter
  def self.getHtmlTagContent(html, tag)
    content = ""
    tag_list = html.source.search(tag)
    if tag_list.size > 0
      content = tag_list.first.inner_html
    end
    return content
  end


end