#= require ../../views/pictures/pictures_item

class Pages.MyyCloud.ImportedContent.PictureItem extends Fragments.PicturesItem

  initialize: ({@modelCollection, @picking})->
    unless @picking
      @setBindings()

  viewPicture: ->
    if @picking
      @$el.toggleClass 'selected'
      if @$el.hasClass 'selected'
        MyApp.vent.trigger 'imported_picture:picked', @model
      else
        MyApp.vent.trigger 'imported_picture:unpicked', @model
    else
      super()

    false