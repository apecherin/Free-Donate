class Pages.Messages.MessageItem extends Backbone.Marionette.ItemView
  template: "pages/messages/message"
  className: 'message-item-container'

  events:
    'click .message-user' : 'goToUserProfile'
    'click .row-message' : 'goToMessageDetail'

  initialize: (options)->
    @type = options.type

  onRender: ->

  goToMessageDetail: ->
    MyApp.vent.trigger 'message:show', {type: @type, message: @model}

  goToUserProfile: (event)->
    target = $(event.target)
    Backbone.history.navigate(Routers.Main.showUserProfilePath(target.data("target")), true)
    false

  serializeData: ->
    message: @model
    type: @type
