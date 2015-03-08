class Modals.SharesButtons extends Backbone.Marionette.Layout
  template: 'modals/shares_buttons'

  regions:
    pictureThumbnailsGenerator:  '#picture-thumbnails-generator'

  events:
    'click .shares-buttons a' : 'share'

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
    comparisonShare = new Models.ComparisonTableShare
      comparison_table_id: @model.id
    comparisonShare.save {url: document.URL, network_type: type}, success: =>
      MyApp.vent.trigger('comparison_shares:new')
    false

  serializeData: ->