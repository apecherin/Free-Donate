class Pages.Messages.NewMessage extends Backbone.Marionette.ItemView
  template: "pages/messages/new"
  tagName: 'ul'

  initialize: (options)->

  events:
    'submit #message-form': "submitMessage"
    'click .reset':   "resetMessage"

  onRender: ->

  submitMessage: (event)->
    event.preventDefault()
    target = $(event.target)
    newMessage =
      subject: target.find('.subject').val()
      receiver: target.find('.receiver').val()
      body: target.find('.body').val()

    message = new Models.Message
    message.set newMessage
    message.save null,
      wait: true
      success: (model, response)=>
        Backbone.history.loadUrl Routers.Main.showMyPeopleMessagesPath('sent')
      error: =>
        @$("#message-form .error").text("Invalid username.")

  resetMessage: (event)->
    @$("#message-form .subject").val("")
    @$("#message-form .receiver").val("")
    @$("#message-form .body").val("")

