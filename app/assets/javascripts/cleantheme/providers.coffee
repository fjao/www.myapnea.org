@providersReady = () ->
  $("#video-play").mouseleave ->
    $(this).children("i").animate
      backgroundColor: "rgba(250,250,250,.43)"
      , 300
    return

  $("#video-play").mouseenter ->
    $(this).children("i").filter(':not(:animated)').animate
      backgroundColor: "#FFA400"
      , 300
    return
  # allow provider quote to stay static at top
  $(window).scroll ->
    if window.innerWidth > 768
      if $(this).scrollTop() > 600
        $("#provider-banner").addClass "fixed-under-nav"
        $("#community-tracker-provider").css('padding-top', $("#provider-banner").outerHeight() + 10)
      else
        $("#provider-banner").removeClass "fixed-under-nav"
        $("#community-tracker-provider").css('padding-top', 15)
      return
