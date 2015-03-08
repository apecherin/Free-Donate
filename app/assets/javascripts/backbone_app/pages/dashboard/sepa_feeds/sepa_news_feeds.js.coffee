class Pages.Dashboard.SepaNewsFeeds extends Backbone.Marionette.Layout
  template: 'pages/dashboard/sepa_news_feeds'

  regions:
    quick_buttons:      '#quick-buttons'
    likes_and_comments: '#likes-and-comments'
    who_to_follows:     '#who-to-follows'

  initialize: ({ @suitable_people })->

  onRender: ->
    @quick_buttons.show new Pages.Dashboard.QuickButtons
    @likes_and_comments.show new Pages.Dashboard.LikesAndComments
    @who_to_follows.show new Pages.Dashboard.WhoToFollows collection: @suitable_people

  serializeData: ->