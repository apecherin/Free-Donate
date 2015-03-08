class Fragments.Vehicles.GalleriesItem extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/galleries_item'
  tagName: 'li'

  events:
    'click a.show-gallery' : 'viewGallery'

  initializeSortable: Views.Mixins.initializeSortableItem

  initialize: ->
    @bindTo @, 'render', @initializeSortable

  onRender: ->
    @$el.attr('id', 'thumbnail_' + @model.id)

  serializeData: ->
    gallery: @model

  viewGallery: ->
    Backbone.history.navigate(Routers.Main.showVehicleGalleryPath(@model, @model.get("vehicle")))
    view = new Pages.Galleries.Show(gallery: @model)
    MyApp.layout.content.show(view)
    false
