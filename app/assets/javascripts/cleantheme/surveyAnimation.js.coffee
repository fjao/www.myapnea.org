@surveyAnimationReady = () ->

  # Initiate with focus on first question
  $(document).ready ->
    $(".survey-first-question").focus()
    $(this).scrollTop 0
    return
  $(window).on "beforeunload", ->
    $(window).scrollTop 0
    return

  # Scroll to active question
  @nextQuestionScroll = (element1, element2) ->
    # Check for multiple questions, and position the first question in the center
    if element2.find('.current').length > 0
      currentHeight = element2.find('.current').offset().top
      elementOffsetHeight = element2.find('.current').outerHeight() / 2
      console.log "found multiple questions"
    else
      currentHeight = element2.offset().top
      elementOffsetHeight = element2.outerHeight() / 2
    offsetHeight = $(window).outerHeight() / 2
    # Check for large questions on small screens
    if elementOffsetHeight > offsetHeight
      newHeight = currentHeight - 91
    else
      newHeight = currentHeight - offsetHeight + elementOffsetHeight
    $("body").animate
      scrollTop: newHeight
    , 400
    , "swing"
    , ->
      console.log "Scrolled!"
      changeFocus(element1, element2)
      return

  # Change focus
  @changeFocus = (question1, question2) ->
    $(question1).find("input").blur()
    $(question2).find("input").focus()

  # Progress to next question
  @assignQuestion = (next, prev) ->
    activeQuestion = $(".survey-container.active")
    if (next and activeQuestion.next().length) or (prev and activeQuestion.prev().length)
      activeQuestion.removeClass "active"
      if next
        activeQuestion.next().addClass "active"
      else if prev
        activeQuestion.prev().addClass "active"
      newActiveQuestion = $(".survey-container.active")
      nextQuestionScroll(activeQuestion, newActiveQuestion)


  # Progress to next part in multiple-part question
  @assignMultipleQuestion = (next, prev) ->
    activeQuestion = $(".multiple-question-container.current")
    if (next and activeQuestion.next().length) or (prev and activeQuestion.prev().length)
      activeQuestion.removeClass "current"
      if next
        activeQuestion.next().addClass "current"
      else if prev
        activeQuestion.prev().addClass "current"
      newActiveQuestion = $(".multiple-question-container.current")
      nextQuestionScroll(activeQuestion, newActiveQuestion)
    else if (next and !activeQuestion.next().length)
      assignQuestion(true, false)
    else if (prev and !activeQuestion.prev().length)
      assignQuestion(false, true)


  # Respond to user clicking different questions
  $('.survey-container').click (e) ->
    if $(e.target).hasClass "next-question"
      assignQuestion(true, false)
    else
      unless $(this).hasClass "active"
        activeQuestion = $(".survey-container.active")
        activeQuestion.removeClass "active"
        $(this).addClass "active"
        newActiveQuestion = $(".survey-container.active")
        if $(this).prev().length == 0
          console.log "clicked first question"
          $("body").animate
            scrollTop: 0
          , 400
          , "swing"
        else
          nextQuestionScroll(activeQuestion, newActiveQuestion)


  # Respond to keystrokes
  $("body").keydown (e) ->
    if $(".survey-container.active").hasClass "progress-w-number"
        inputs = $(".survey-container.active .multiple-question-container.current").find("input:radio")
        if e.keyCode is 38
          e.preventDefault()
          assignMultipleQuestion(false, true)
        else if e.keyCode is 40
          e.preventDefault()
          assignMultipleQuestion(true, false)
        else
          inputs.each (index) ->
            key = inputs[index].value.charCodeAt(0)
            if e.keyCode is key
              $(inputs[index]).prop "checked", true
              assignMultipleQuestion(true, false)
    else if e.keyCode is 38
      e.preventDefault()
      assignQuestion(false, true)
    else if e.keyCode is 40
      e.preventDefault()
      assignQuestion(true, false)
    else
      if $(".survey-container.active").hasClass "progress-w-enter"
        if e.keyCode is 13
          assignQuestion(true, false)
      if $(".survey-container.active").hasClass "progress-w-letter"
        inputs = $(".survey-container.active").find("input:radio")
        inputs.each (index) ->
          key = inputs[index].value.charCodeAt(0)
          if e.keyCode is key
            $(inputs[index]).prop "checked", true
            assignQuestion(true, false)
      if $(".survey-container.active").hasClass "check-w-letter"
        inputs = $(".survey-container.active .input-container").find("input:checkbox")
        inputs.each (index) ->
          key = inputs[index].value.charCodeAt(0)
          if e.keyCode is key
            if $(inputs[index]).prop "checked"
              $(inputs[index]).prop "checked", false
            else
              $(inputs[index]).prop "checked", true

  # Respond to conditional inputs
  # https://github.com/remomueller/slice/blob/master/app/assets/javascripts/global.js.coffee#L164
  $(".reveal-next-input").click (e) ->
    changeFocus($(this), $(this).next('.hidden-input'))
