#= require './news_feeds_item_layout'

class Pages.Dashboard.NewsFeeds extends Backbone.Marionette.CollectionView
  itemView: Pages.Dashboard.NewsFeedsItemLayout
  tagName: 'ul'

  initialize: ({@myNews, @followingsNews, @followersNews})->
    @myNews = if typeof(@myNews) is 'undefined' then false else @myNews
    @followingsNews = if typeof(@followingsNews) is 'undefined' then false else @followingsNews
    @followersNews = if typeof(@followersNews) is 'undefined' then false else @followersNews
    @itemViewOptions = =>
      myNews: @myNews
      followingsNews: @followingsNews
      followersNews: @followersNews