#= require backbone_app/pages/vehicles/galleries_item

class Pages.Albums.AlbumItem extends Fragments.Vehicles.GalleriesItem
  template: 'pages/albums/album_item'

  tagName: 'li'
  events:
    'click a.show-gallery' : 'viewGallery'

  onRender: ->
    @$el.attr('id', 'thumbnail_' + @model.id)

  serializeData: ->
    source:  @model.get('cover_picture_url')
    title:   @model.get('title') || I18n.t('untitled_gallery', scope: 'vehicles.galleries')
    altText: @model.get('cover_picture_alt') || "#{I18n.t('gallery', scope: 'vehicles.galleries')} #{@model.id}"
    hasUrl:  if @model.get('cover_picture_url') then 'has-url' else 'no-url'

  viewGallery: ->
    @model.get('pictures').fetch
      success: =>
        Backbone.history.navigate Routers.Main.showUserPinsAlbumPath(@model)
        MyApp.layout.content.show new Pages.Albums.UserGallery gallery: @model
    false
