#= require ./shares_buttons
class Modals.CommonSharesButtons extends Modals.SharesButtons

  onRender: ->

  initialize: ({@page_url}) ->
    @page_url = window.location.host + '/' + @page_url
    @sharesURLS = {
      'facebook' : 'https://www.facebook.com/sharer/sharer.php?u=',
      'twitter' : 'http://twitter.com/share?url=',
      'google' : 'https://plus.google.com/share?url='
    }

  share: (e) ->
    width = 575
    height = 400
    type = @$(e.target).data('type')
    left = ($(window).width() - width) / 2
    top = ($(window).height() - height) / 2
    opts = "status=1" + ",width=" + width + ",height=" + height + ",top=" + top + ",left=" + left
    window.open @sharesURLS[type] + @page_url, type, opts
    false