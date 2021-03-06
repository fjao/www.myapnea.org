require "test_helper"

class SurveyTest < ActiveSupport::TestCase

  test "#self.load_from_file" do
    assert_difference "Survey.count" do
      Survey.load_from_file("about-me")
    end

    survey = Survey.find_by_name_en("About Me")

    assert_not_nil survey

    assert_equal "about-me", survey.slug
    assert_equal 10, survey.default_position
    assert_equal 6, survey.questions.length, "hmm: #{survey.questions.map(&:slug)}"

    assert_match /What is your date of birth?/, survey.questions.first.text

    cb_q = survey.questions.where(slug: "race").first

    assert cb_q
    assert_equal 2, cb_q.answer_templates.length
    assert_match /American Indian or Alaskan Native/, cb_q.answer_templates.first.answer_options.first.text
    assert_equal "A", cb_q.answer_templates.first.answer_options.first.hotkey
    assert_equal 1, cb_q.answer_templates.first.answer_options.first.value
    assert_equal 6, cb_q.answer_templates.last.target_answer_option
    assert_equal 2, cb_q.answer_templates.count

    assert_no_difference "Survey.count" do
      Survey.load_from_file("about-me")
    end

    survey.reload
    cb_q = survey.questions.where(slug: "race").first

    assert_equal 2, cb_q.answer_templates.count


  end

  test "All defined surveys should load with no problem" do
    assert_difference "Survey.count", Survey::SURVEY_LIST.length do
      Survey::SURVEY_LIST.each {|survey_slug| Survey.load_from_file(survey_slug)}


    end

  end

  test "Question list methods" do
    assert_difference "Survey.count" do
      Survey.load_from_file("about-me")
    end

    s = Survey.find_by_slug("about-me")


    assert_equal s.all_questions_descendants.length, s.questions.to_a.length
    assert_equal s.all_questions_descendants.map(&:text_en).sort, s.questions.map(&:text_en).sort
    assert_equal s.questions.count, s.ordered_questions.count
    assert_equal s.questions, s.ordered_questions
    assert_equal s.questions.length, s.questions.count

  end


  # test "self.migrate_old_answers" do
  #
  #   question_map = [{"slug" => "favorite-color", "answer_template_name" => "color_list", "id" => questions(:q1).id.to_s }]
  #   survey = Survey.find_by_slug("hidden-survey")
  #
  #   assert_difference "AnswerSession.count", 2 do
  #     Survey.migrate_old_answers("hidden-survey", question_map)
  #   end
  #
  #
  #   unmapped_question = questions(:number2)
  #   mapped_question = questions(:radio2)
  #
  #   assert_equal 0, unmapped_question.answers.count
  #   assert_equal 2, mapped_question.answers.count
  #
  #   assert_equal "migrated", mapped_question.answers.first.state
  #
  #   assert_includes mapped_question.answers.map{|a| a.show_value}, "red"
  #   assert_includes mapped_question.answers.map{|a| a.show_value}, "blue"
  #
  # end


  test "#launch_single" do
    u = users(:social)

    assert_empty u.assigned_surveys

    assert_difference "u.assigned_surveys.count" do
      result = surveys(:new).launch_single(u, "baseline")
      assert_nil result
    end

    assert_equal surveys(:new), u.assigned_surveys.last
    assert_equal surveys(:new).default_position, u.answer_sessions.last.position


    assert_equal u, surveys(:new).launch_single(u, "baseline")



  end

  test "#launch_multiple" do

    assert_difference "AnswerSession.where(encounter: 'baseline').count", User.current.where(adult_diagnosed: true).count do
      result = surveys(:new_2).launch_multiple(User.current.where("adult_diagnosed = TRUE"), 'baseline')
      assert_empty result
    end

    assert_equal User.current.where(adult_diagnosed: true), surveys(:new_2).launch_multiple(User.current.where("adult_diagnosed = TRUE"), 'baseline')
  end

end
