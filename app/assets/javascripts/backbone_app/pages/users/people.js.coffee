class Pages.Users.People extends Backbone.Marionette.Layout
  template: 'pages/users/people'
  id: 'people'

  events:
    'click ul.nav-tabs li > a' : 'tabClicked'

  regions:
    breadcrumb:          '#breadcrumb'
    followingsContent: '#followings'
    followersContent:  '#followers'


  initialize: ({@followings, @followers, @activeTab})->
    @tab = @activeTab
    @activeFollowingFetchrequest = 0
    @followings.each (following)=>
      @activeFollowingFetchrequest += 1
      following.thing.fetch
        success: =>
          @activeFollowingFetchrequest -= 1
          @renderFollowings()

  renderFollowings: ->
    if @activeFollowingFetchrequest is 0
      @followingsContent.show new Fragments.Users.People.Followings
        user: @model
        collection: new Backbone.Collection @followings.map (following)=> following.thing

  onRender: ->
    callback = =>
      @activeTab = if ["followings", "followers", "blocked", "filter"].indexOf(@activeTab) == -1 then "followings" else @activeTab
      @renderBreadcrumbs()

      @followersContent.show new Fragments.Users.People.Followings
        user: @model
        collection: @followers

      if @activeTab?
        if @activeTab == 'filter'
          @$('.nav-tabs a[data-target="#followings"]').tab('show')
        else
          @$('.nav-tabs a[data-target="#' + @activeTab + '"]').tab('show')

    setTimeout callback, 0

  tabClicked: (event)->
    target = $(event.target)

    if target.data('target')?
      @activeTab = target.data('target').substr(1)
      @renderBreadcrumbs()

    target.tab('show')
    false

  renderBreadcrumbs: ->
    if @tab == 'filter'
      renderTab = 'filter'
    else
      renderTab = @activeTab

    Backbone.history.navigate Routers.Main.showPeoplePath(renderTab)
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forPeopleFollowings(renderTab)

  serializeData: ->
    activeTab: @activeTab