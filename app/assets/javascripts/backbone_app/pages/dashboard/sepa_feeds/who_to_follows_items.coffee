#= require './who_to_follows_item'
class Pages.Dashboard.WhoToFollowsItems extends Backbone.Marionette.CollectionView
  className: 'to-follow-content'
  itemView: Pages.Dashboard.WhoToFollowsItem

  initialize: ({ @collection })->

  onRender: ->