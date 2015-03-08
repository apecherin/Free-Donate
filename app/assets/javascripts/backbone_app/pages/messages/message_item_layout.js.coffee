class Pages.Messages.MessageItemLayout extends Backbone.Marionette.Layout
  template: 'pages/messages/layout'
  className: 'message-item'

  initialize: (options)->
    @type = options.type

  regions:
    content: '.content'

  onRender: ->
    @content.show new Pages.Messages.MessageItem
      model: @model
      type: @type
    @$el.attr 'id', HAML.globals()['domId'](@model)


