class Pages.Albums.AlbumsLayout extends Backbone.Marionette.Layout
  template: 'pages/albums/albums'

  regions:
    albumsContainer: '#albums'

  initialize: ({@albums})->

  onRender: ->
    @albumsContainer.show new Pages.Albums.Albums collection: @albums