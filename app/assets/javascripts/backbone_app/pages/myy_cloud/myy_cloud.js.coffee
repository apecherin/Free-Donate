#= require backbone_app/pages/myy_cloud/imported_content/imported_content
#= require ./galleries/galleries

class Pages.MyyCloud.Layout  extends Backbone.Marionette.Layout
  template: 'pages/myy_cloud/layout'
  id: 'myy_cloud'

  regions:
    profilePictures  : '#profile_pictures'
    publicGalleries  : '#pub'
    privateGalleries : '#priv'
    softwareSetup    : '#inst'
    breadcrumb       : '#breadcrumb'

  events:
    'click .simple-tab'        : 'tabClicked'
    'click .load-more'         : 'loadPictures'

  initialize: ({@pictures, @activeTab, @albums, @user})->
    @activeTab ||= 'imp'
    @page = 1

    @bindTo MyApp.vent, 'pictures:deleted', =>
      @albums.fetch
        success: =>
          @render()

  onRender: ->
    callback = =>
      @renderBreadcrumbs()

      @privateGalleries.show new Pages.MyyCloud.Pins
        userPins: new Collections.Albums @albums.where(privacy: 'private')

      @publicGalleries.show new Pages.MyyCloud.Pins
        userPins: new Collections.Albums @albums.where(privacy: 'public')

      @profilePictures.show new Pages.MyyCloud.ImportedContent pictures: @pictures, albums: @albums
      @softwareSetup.show new Pages.MyyCloud.SoftwareSetup

      if @activeTab?
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
    Backbone.history.navigate Routers.Main.myyCloudPath(@activeTab, @user)
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forMyyCloud(@activeTab, @user)

  loadPictures: ->
    @page += 1

    @pictures.fetch
      data: {page: @page}
      add: true

    false

  serializeData: ->
    user: @user