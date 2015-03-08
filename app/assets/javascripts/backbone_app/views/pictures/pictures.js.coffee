#= require ./pictures_item

class Fragments.Pictures extends Backbone.Marionette.CompositeView
  template: 'fragments/pictures/pictures'
  itemView: Fragments.PicturesItem

  initialize: ({@collection, @canManage, @showPicture})->
    @showPicture = if typeof(@showPicture) is 'undefined' then false else @showPicture
    if @showPicture
      @viewPicture(@collection.get(@showPicture))

  itemViewOptions: ->
    modelCollection: @collection
    showPicture: @showPicture

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.thumbnails').append(itemView.el)

  viewPicture: (model) ->
    model.setPictureUrl()
    MyApp.vent.trigger 'check:pictures:order', model
    MyApp.modal.show new Pages.Pictures.Show
      picture: model
      pictures: @collection
    false