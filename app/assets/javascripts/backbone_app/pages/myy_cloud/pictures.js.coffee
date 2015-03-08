#= require ../../views/pictures/pictures
#= require ./picture_item

class Pages.MyyCloud.ImportedContent.Pictures extends Fragments.Pictures
  itemView: Pages.MyyCloud.ImportedContent.PictureItem

  initialize: ({@canManage, @picking})->

  itemViewOptions: ->
    modelCollection: @collection
    picking: @picking
