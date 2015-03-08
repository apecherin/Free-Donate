#= require libs/noty/jquery.noty
#= require libs/noty/layouts/topCenter
#= require libs/noty/themes/default

$ = jQuery

$.noty.defaults.timeout = 8000
$.noty.defaults.layout = 'topCenter'

class Lib.Notifications
  @bindNoty: (message, type, timeout=$.noty.defaults.timeout)->
    noty text: message, type: type, layout: 'topCenter', dismissQueue: true, timeout: timeout