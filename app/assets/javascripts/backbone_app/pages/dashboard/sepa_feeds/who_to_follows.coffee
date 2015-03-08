#= require './who_to_follows_item'
class Pages.Dashboard.WhoToFollows extends Backbone.Marionette.Layout
  template: 'pages/dashboard/sepa_news_feeds/who_to_follows'
  regions:
    content: '.content'

  initialize: ({ @collection })->

  onRender: ->
    @content.show new Pages.Dashboard.WhoToFollowsItems collection: @collection