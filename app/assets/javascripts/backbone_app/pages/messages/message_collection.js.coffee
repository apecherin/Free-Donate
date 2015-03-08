#= require './message_item_layout'

class Pages.Messages.MessageCollection extends Backbone.Marionette.CollectionView
  itemView: Pages.Messages.MessageItemLayout
  tagName: 'ul'

  initialize: (options)->
    @options = options

  itemViewOptions: (model, index)->
    type: @options.collection.mailbox
