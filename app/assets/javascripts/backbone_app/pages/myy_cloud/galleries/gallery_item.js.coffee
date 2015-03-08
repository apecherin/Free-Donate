#= require ./gallery
#= require backbone_app/pages/vehicles/galleries_item

class Pages.MyyCloud.GalleryItem extends Fragments.Vehicles.GalleriesItem
  template: 'pages/myy_cloud/galleries/gallery_item'

  tagName: 'li'
  events:
    'click a.show-gallery' : 'viewGallery'

  initialize: ({@model})->
    @private = @model.get('privacy') is 'public'

  onRender: ->
    @$el.attr('id', 'thumbnail_' + @model.id)

  viewGallery: ->
    @model.get('pictures').fetch
      success: =>
        Backbone.history.navigate Routers.Main.showUserAlbumPath(@model.get('user'), @model)
        MyApp.layout.content.show new Pages.MyyCloud.Gallery gallery: @model
    false

  serializeData: ->
    private: @private
    source:  @model.get('cover_picture_url')
    title:   @model.get('title') || I18n.t('untitled_gallery', scope: 'vehicles.galleries')
    altText: @model.get('cover_picture_alt') || "#{I18n.t('gallery', scope: 'vehicles.galleries')} #{@model.id}"
    hasUrl:  if @model.get('cover_picture_url') then 'has-url' else 'no-url'
