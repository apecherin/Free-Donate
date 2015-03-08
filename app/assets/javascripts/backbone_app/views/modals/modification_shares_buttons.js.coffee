#= require ./shares_buttons
class Modals.ModificationSharesButtons extends Modals.SharesButtons

  onRender: ->

  initialize: ({@model}) ->
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
    window.open @sharesURLS[type] + document.URL, type, opts
    modificationShare = new Models.ModificationShare
      modification_id: @model.id
    modificationShare.save {url: document.URL, network_type: type}, success: =>
      MyApp.vent.trigger('modification_shares:new')
    false