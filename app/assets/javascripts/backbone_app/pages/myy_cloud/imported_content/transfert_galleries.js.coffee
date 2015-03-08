#= require ./transfert_gallery_item

class Pages.MyyCloud.TransfertGalleries extends Pages.MyyCloud.Galleries
  itemView: Pages.MyyCloud.TransfertGalleryItem

  initialize: ({@pictures, @galleryPrivacy})->

  itemViewOptions: ->
    pictures: @pictures
    galleryPrivacy: @galleryPrivacy