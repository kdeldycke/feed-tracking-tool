require File.dirname(__FILE__) + '/../test_helper'
require 'recap_controller'

# Re-raise errors caught by the controller.
class RecapController; def rescue_action(e) raise e end; end

class RecapControllerTest < Test::Unit::TestCase
  def setup
    @controller = RecapController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
