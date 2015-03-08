class Pages.Users.ProList.Dashboard extends Backbone.Marionette.Layout
  template: 'pages/users/pro_list/dashboard'
  className: 'user-pro-list'

  regions:
    breadcrumb: '#breadcrumb'
    oem:        '#oem'
    suppliers:  '#suppliers'
    vendors:    '#vendors'

  events:
    'click ul.nav-tabs li > a' : 'tabClicked'
    'click .edit-avatar' : 'goToUserProfilePage'

  initialize: ({@user, @activeTab, @isPopup})->
    @activeTab = if @activeTab? then @activeTab else 'oem'
    @isPopup = if @isPopup? then @isPopup else false

  onRender: ->
    if @activeTab?
      callback = =>
        @$('.nav-tabs a[data-target="#' + @activeTab + '"]').tab('show')
      setTimeout(callback, 0)

    user_makers = new Collections.UserMakers
    user_makers.fetch data: {user_id: @user.id}, success: (user_makers) =>
      @oem.show new Pages.Users.ProList.Maker makersType: 'Manufacturer', makers: new Collections.UserMakers(user_makers.where(type: 'Manufacturer')), user: @user
      @suppliers.show new Pages.Users.ProList.Maker makersType: 'Supplier', makers: new Collections.UserMakers(user_makers.where(type: 'Supplier')), user: @user
      @vendors.show new Pages.Users.ProList.Maker makersType: 'Vendor', makers: new Collections.UserMakers(user_makers.where(type: 'Vendor')), user: @user

    @renderBreadcrumbs()

  renderBreadcrumbs: ->
    if !@isPopup
      @breadcrumb.show new Fragments.Breadcrumb.Index
        collection: Collections.Breadcrumbs.forProList(@user, @activeTab)

  tabClicked: (event) ->
    target = $(event.target)
    if target.data('target')?
      @activeTab = target.data('target').substr(1)
      if !@isPopup
        @renderBreadcrumbs()
    if !@isPopup
      Backbone.history.navigate Routers.Main.showUserProListPath(@user, @activeTab)

    target.tab('show')
    false

  goToUserProfilePage: (e) ->
    $target = $(e.currentTarget)
    userId = $target.data('user-id')
    return false unless userId
    userProfilePath = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate(userProfilePath, true)
    false

  serializeData: ->
    user: @user
    isPopup: @isPopup