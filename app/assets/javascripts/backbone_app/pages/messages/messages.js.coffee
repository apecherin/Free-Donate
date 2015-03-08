class Pages.Messages.Message extends Backbone.Marionette.Layout
  template: 'pages/messages/messages'

  events:
    'click ul.nav-tabs li > a' : 'tabClicked'

  regions:
    breadcrumb: '#breadcrumb'
    inbox:   '#inbox'
    sent:   '#sent'
    trash:   '#trash'
    newMessage: '#newMessage'
    unreadCount: '#unreadCount'

  initialize: ({ @inbox_messages, @sent_messages, @trash_messages, @tab})->
    @activeTab = @tab
    @bindTo(MyApp.vent, 'uneadMessageCount:updated', @updateUnreadMessageCount)
    @bindTo(MyApp.vent, 'message:show', @goToMessage)

  onRender: ->
    if Store.get('currentUser')?
      unreadMessageCount = new Models.UnreadMessageCount
      unreadMessageCount.fetch success: =>
        count = unreadMessageCount.get('count')
        @unreadCount.show new Pages.Messages.UnreadCount
          count: unreadMessageCount.get('count')
    callback = =>
      @breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forPeopleFollowings('messages')

      @inbox.show new Pages.Messages.MessageCollection
        collection: @inbox_messages

      @sent.show new Pages.Messages.MessageCollection
        collection: @sent_messages

      @trash.show new Pages.Messages.MessageCollection
        collection: @trash_messages

      @newMessage.show new Pages.Messages.NewMessage

      if @activeTab?
        @$('.nav-tabs a[data-target="#' + @activeTab + '"]').tab('show')

    setTimeout callback, 0

  tabClicked: (event)->
    target = $(event.target)

    if target.data('target')?
      @activeTab = target.data('target').substr(1)
    else
      target = @$("a.inbox-tab")
      @activeTab = "inbox"

    target.tab('show')
    false

  goToMessage: (options) ->
    read = options['message'].get('read')
    message = new Models.Message(id: options['message'].id)
    message.collection = new Collections.Messages
    message.fetch success: =>
      if options['type'] == "inbox"
        @inbox.show new Pages.Messages.MessageDetails
          model: options['message']
          type: options['type']

      if options['type'] == "sent"
        @sent.show new Pages.Messages.MessageDetails
          model: options['message']
          type: options['type']

      if options['type'] == "trash"
        @trash.show new Pages.Messages.MessageDetails
          model: options['message']
          type: options['type']

    false

  updateUnreadMessageCount: (count)->
    @unreadCount.show new Pages.Messages.UnreadCount
      count: count


  serializeData: ->
    activeTab: @activeTab