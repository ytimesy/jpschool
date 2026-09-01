require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  test "posting the first answer renders the second question" do
    post lesson_quiz_url(lesson_id: 1), params: {
      authenticity_token: authenticity_token,
      question: 1,
      answers: { "1" => "2" }
    }

    assert_response :success
    assert_select "p", text: /2 \//
    assert_select "h3", text: /Q2/
    assert_select "input[type=hidden][name='answers[1]'][value='2']"
  end

  test "posting the final answer scores all submitted answers" do
    post lesson_quiz_url(lesson_id: 1), params: {
      authenticity_token: authenticity_token,
      question: 2,
      answers: { "1" => "2", "2" => "1" }
    }

    assert_response :success
    assert_select ".score-card h2", text: /100/
    assert_select ".score-card p", text: /2/
  end

  private

  def authenticity_token
    get lesson_quiz_url(lesson_id: 1)
    assert_response :success

    response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)[1]
  end
end
