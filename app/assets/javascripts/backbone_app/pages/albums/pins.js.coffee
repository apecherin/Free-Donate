class Pages.Albums.Pins extends Backbone.Marionette.Layout
  template: 'pages/albums/pins'

  regions:
    breadcrumb:  '#breadcrumb'
    albumsList:  '#albums-list'
    adContainer: '.ad-container'

  initialize: ({@userPins})->


  onRender: ->
    @breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forAlbums()
    @albumsList.show new Pages.Albums.AlbumsLayout albums: @userPins
    @adContainer.show new Pages.Ads.Ad_300x600