require File.dirname(__FILE__) + '/../test_helper'
require 'rssfeed_controller'

# Re-raise errors caught by the controller.
class RssfeedController; def rescue_action(e) raise e end; end

class RssfeedControllerTest < Test::Unit::TestCase
  def setup
    @controller = RssfeedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
