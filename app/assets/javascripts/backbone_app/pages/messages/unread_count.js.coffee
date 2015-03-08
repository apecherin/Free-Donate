class Pages.Messages.UnreadCount extends Backbone.Marionette.ItemView
  template: "pages/messages/unread_count"
  className:  "unreadCount"

  initialize: (count)->
    @count = count.count

  onRender: ->
    callback = =>
      if @count is 0
        @.undelegateEvents()
        @.$el.removeData().unbind()
        @.$el.remove()
        Backbone.View.prototype.remove.call(@)
    setTimeout(callback, 0)

  serializeData: ->
    count: @count
