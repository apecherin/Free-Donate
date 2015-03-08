window.csrfToken = ->
  $('meta[name=csrf-token]').attr('content')

window.csrfParam = ->
  $('meta[name=csrf-param]').attr('content')
