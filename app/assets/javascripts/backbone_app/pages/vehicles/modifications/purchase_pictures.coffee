#= require ./purchase_picture

class Pages.Vehicles.Modifications.PurchasePictures extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/modifications/purchase_pictures'
  itemView: Pages.Vehicles.Modifications.PurchasePicture

  events:
    'click img' : 'previewPictures'

  initialize: ({@pictures, @modification, @currentPurchasePictureId, @cps_tab})->
    @currentPurchasePictureId = if @currentPurchasePictureId? then @currentPurchasePictureId else null
    @cps_tab = if @cps_tab? @cps_tab else null
    @bindTo MyApp.vent, 'cps_tab:choice', @setCPSTab

  onRender: ->
    if @currentPurchasePictureId?
      @picture_exist = @collection.find (picture) => picture.id is @currentPurchasePictureId.toNumber()
      if @picture_exist?
        @currentPurchasePictureId = null
        @collection.where({fake: true}).remove()
        MyApp.modal.show new Pages.Pictures.Show
          picture : @picture_exist
          pictures: @pictures
          modification: @modification

    @currentPurchasePictureId = null

  itemViewOptions: ->
    currentPurchasePictureId: @currentPurchasePictureId
    pictures: @pictures
    modification: @modification

  appendHtml: (collectionView, itemView)->
    collectionView.$('.pictures').append itemView.el

  setCPSTab: (currentTab, options=null)->
    @cps_tab = options['cps_tab']

  previewPictures: (e, picture=false) ->
    @currentPurchasePictureId = null
    current_picture =
      if picture
        e
      else
        @pictures.find (picture) => picture.id is @$(e.target).attr('data-id').toNumber()

    unless picture
      Backbone.history.navigate Routers.Main.showModificationsConfDomainModPicPath(@modification.get('vehicle'), @modification.get('change_set'), @modification.get('domain'), @modification, current_picture, @cps_tab)

    MyApp.modal.show new Pages.Pictures.Show
      picture : current_picture
      pictures: @pictures
      modification: @modification

    false