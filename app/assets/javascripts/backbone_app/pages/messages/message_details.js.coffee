class Pages.Messages.MessageDetails extends Backbone.Marionette.ItemView
  template: "pages/messages/details"
  className: 'message-details-container'

  initialize: (options)->
    @type = options.type

  events:
    'click .back' : 'backToList'
    'click .reply-message' :  'replyMessage'
    'click .delete-message' :  'deleteMessage'
    'submit #reply-form' : "submitReply"
    'click .cancel-submit' : 'cancelReply'

  onRender: ->

  backToList: (event)->
    Backbone.history.loadUrl Routers.Main.showMyPeopleMessagesPath(@type)
    false

  replyMessage: (event)->
    @$("#actions-containers").hide()
    @$("#reply-container").show()

  deleteMessage: (event)->
    event.preventDefault()
    target = $(event.target)
    @$("#reply-container").hide()
    message = new Models.Message
    message.set('id', target.data("id"))
    message.destroy()
    Backbone.history.loadUrl Routers.Main.showMyPeopleMessagesPath(@type)

  submitReply: (event)->
    event.preventDefault()
    target = $(event.target)
    reply =
      subject: target.find('.subject').val()
      receiver: target.find('.receiver').val()
      body: target.find('.body').val()

    message = new Models.Message
    message.set reply
    message.save null,
      wait: true
      success: (model, response)=>
        @$("#reply-container").hide()
        Backbone.history.loadUrl Routers.Main.showMyPeopleMessagesPath(@type)
      error: =>

  cancelReply: (event)->
    event.preventDefault()
    @$("#actions-containers").show()
    @$("#reply-container").hide()

  serializeData: ->
    message: @model
    type: @type
