require "test_helper"

class ProgressControllerTest < ActionDispatch::IntegrationTest
  test "learner progress page redirects to evaluation" do
    get progress_url

    assert_redirected_to evaluation_url
  end
end
