Fragments.Collages.CutoutsItem = Backbone.Marionette.ItemView.extend
  tagName:  'li'
  template: 'fragments/collages/cutouts_item'

  events:
    'click .cutout'      : 'handleCutout'

  initialize: (attributes)->
    @modeOnlyList = attributes.modeOnlyList? and attributes.modeOnlyList == true
    @modeEdit = attributes.modeEdit? and attributes.modeEdit == true
    @bindTo @model, 'change:url', @render
    @model.collection.collage = @model.get('collage') #TODO: fix this quick hack if possible

  serializeData: ->
    cutout:       @model
    modeEdit:     @modeEdit

  onRender: ->
    @$el.attr('data-row', @model.get('row'))
    @$el.attr('data-col', @model.get('col'))

  handleCutout: (e) ->
    unless @modeOnlyList
      if @model.get('type') == 'picture'
        @handleCutoutPicture()
      else
        @handleCutoutVideo()

  handleCutoutPicture: ->
    @collage = @model.get('collage')
    if @model.get('collage') instanceof Models.ProfileCollage
      if @modeEdit
        Store.get('currentUser').get('pictures').fetch success: (collection) =>
          MyApp.modal.show new Pages.Pictures.Show
            picture : collection.first()
            pictures: collection
            cutout  : @model
      else
        gallery = @model.get('picture').get('gallery')
        if gallery instanceof Models.Gallery
          vehicle = gallery.get('vehicle')
          Backbone.history.navigate(Routers.Main.showVehicleGalleryPath(gallery, vehicle), true)
        else
          vehicle = new Models.Vehicle(id: gallery.vehicle.id)
          vehicle.collection = new Collections.Vehicles
          vehicle.fetch success: ->
            Backbone.history.navigate(Routers.Main.showVehicleGalleryPath(gallery, vehicle), true)
    else if @collage.get('active_layout')? && @collage.get('active_layout') is "layout-14"
      if @modeEdit
        @model.get('collage').get('vehicle').get('all_gallery_pictures').fetch success: (collection) =>
          if collection.length
            MyApp.modal.show new Pages.Pictures.Show
              picture : collection.first()
              pictures: collection
              cutout  : @model
          else
            $('.show-galleries').click()
      else
        @model.get('collage').get('vehicle').get('all_gallery_pictures').fetch success: (collection) =>
          if collection.length
            MyApp.modal.show new Pages.Pictures.Show
              picture : collection.first()
              pictures: collection
              cutout  : @model
          else
            $('.show-galleries').click()
        #Backbone.history.navigate(Routers.Main.showVehicleIdentificationPath(@model.get('collage').get('vehicle')), true)
    else
      picture = if @modeEdit then @model.get('collage').get('gallery').get('pictures').at(0) else @model.get('picture')
      if picture
        MyApp.modal.show new Pages.Pictures.Show
          picture: picture
          cutout:  @model if @modeEdit
    false

  handleCutoutVideo: ->
    MyApp.modal.show new Modals.Collages.CutoutsVideoNew
      model: @model
    false
