#= require backbone_app/views/mixins/sortable
#= require ./galleries_item
Fragments.Vehicles.Galleries = Backbone.Marionette.CompositeView.extend
  template: 'fragments/vehicles/galleries'
  itemView: Fragments.Vehicles.GalleriesItem

  events:
    'change .add-gallery' : 'addGallery'

  initializeSortable: Views.Mixins.initializeSortable

  initialize: ({})->
    @canManage = Models.Ability.canManageVehicle @model
    @bindTo @, 'render', @initializeSortable if @canManage

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.thumbnails').prepend(itemView.el)

  addGallery: ->
    fileInput = @$('.add-gallery')
    filesList = fileInput.get(0).files || [name: fileInput.get(0).value]

    gallery = new Models.Gallery
    gallery.set  vehicle: @model
    gallery.save(null, wait: true).done =>
      gallery.justCreated = true
      view = new Pages.Galleries.Show
        gallery: gallery
        addPicturesList: filesList
      view.trigger('gallery:edit')
      MyApp.layout.content.show(view)
      Backbone.history.navigate "vehicles/#{@model.id}/galleries/#{gallery.id}"

    false

  serializeData: ->
    canManage: @canManage
