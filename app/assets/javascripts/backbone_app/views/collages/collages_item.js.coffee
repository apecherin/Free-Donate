class Fragments.CollagesItem extends Backbone.Marionette.ItemView
  tagName:  'li'
  template: 'fragments/collages/collages_item'

  events:
    'click .edit-collage'   : 'editCollage'
    'click .delete-collage' : 'deleteCollage'
    'click .save-collage'   : 'saveCollage'
    'click .move-higher'    : 'moveHigher'
    'click .move-lower'     : 'moveLower'
    'click .lock-unlock'    : 'unblockPictures'
    'click #vehicle-picture' : 'changeVehiclePicture'
    'click input[name=avatar]' : 'stopProp'

  initialize: ({@modeEdit, @modeOnlyList, @iden, @vehicle})->
    @modeOnlyList = @modeOnlyList? and @modeOnlyList
    @iden = @iden? and @iden
    @vehicle = @vehicle? and @vehicle
    @cutouts = @model.get('cutouts')
    @modeEditCollages = @modeEdit
    @modeEditCollage = @model.modeEdit? and @model.modeEdit

  onRender: ->
    callback = =>
      @initializeFileUpload() if @iden
    setTimeout callback, 0

    if @modeEditCollages and @modeEditCollage
      MyApp.vent.trigger 'collage:edit:in'
      @cutouts.fetch success: =>
        render = (layout) =>
          cutouts = new Collections.Cutouts @cutouts.where
            layout: layout
          view = new Fragments.Collages.Cutouts
            collection: cutouts
            modeEdit: true
            modeOnlyList: @modeOnlyList
          view.render()
          view.$el.addClass('item').attr('data-layout', layout)
          @$('.cutouts').append view.el
          coef = if @iden then 4 else 0
          @$('.cutouts').css 'height', @heightOf(cutouts, coef)

        availableLayouts = if @model instanceof Models.ProfileCollage
          Seeds.picLayoutNames
        else if @model instanceof Models.DefaultVehicleCollage
          Seeds.defaultVehicleLayoutNames
        #TODO the some quick monkey patch
        else if @model.get('active_layout')? && @model.get('active_layout') is "layout-14"
          ['layout-14']
        else
          Seeds.galleryLayoutNames
        render layout for layout in availableLayouts

        activeLayout = @model.get('active_layout') || availableLayouts.first()
        @$('.cutouts ul.item[data-layout="' + activeLayout + '"]').addClass('active')
        @$el.addClass('carousel').addClass('slide')
          .attr('id', 'collages-carousel')
          .attr('data-interval', 'false')
        @$('.cutouts').addClass('carousel-inner')
        @$('.carousel-controls').show()
    else
      promise = @cutouts.fetch()
      promise.then =>
        view = new Fragments.Collages.Cutouts
          collection: new Collections.Cutouts(@cutouts.where layout: @model.get('active_layout'))
          modeOnlyList: @modeOnlyList
          modeEdit: false
        view.render()
        @$('.cutouts').append view.el
        @$('.cutouts ul').attr('data-layout', @model.get('active_layout'))
        @$('.edit-controls').show() if @modeEdit
        @$('.cutouts').css 'height', @heightOf @cutouts

      @$el.attr('id', 'collage_' + @model.id)

  heightOf: (cutouts, coef=0)->
    cutout = cutouts.max (cutout)-> cutout.get('height')
    cutout?.get('height') + coef

  unblockPictures: ->
    @modeOnlyList = !@modeOnlyList
    @render()
    false

  saveCollage: ->
    if @isCollageValid()
      @$el.removeAttr('id')
      @model.set active_layout: @$('.cutouts ul.item.active').attr('data-layout')
      @model.save {}, wait: true, success: =>
        @modeEditCollage = @model.modeEdit = false
        @render()
        MyApp.vent.trigger 'collage:edit:out'

  # all images have to be filled for the active cutout layout
  isCollageValid: ->
    @$('.cutouts ul.item.active img.no-url').length is 0

  editCollage: ->
    @modeEditCollage = true
    @render()
    false

  deleteCollage: ->
    bootbox.confirm(
      'Are you sure?',
      (submit)=>
        if submit
          @model.destroy {wait: true}
    )
    false

  moveHigher: ->
    @moveCurrent 'higher'

  moveLower: ->
    @moveCurrent 'lower'

  moveCurrent: (direction)->
    otherElem = if direction == 'higher' then @$el.prev() else @$el.next()
    if otherElem.length == 1
      collageAttrs =
        move: direction
      @model.save collageAttrs, wait: true, success: =>
        @model.set('move', null)
        if direction == 'higher'
          @$el.insertBefore(otherElem)
        else
          @$el.insertAfter(otherElem)
    false

  changeVehiclePicture: ->
    if @iden && !@modeOnlyList
      @$('input[name=avatar]').click()
    false

  stopProp: (event)->
    event.stopPropagation()

  initializeFileUpload: ()->
    $fileInputs = @$('.vehicle-picture input[type=file]')
    if $fileInputs.length is 0 || $fileInputs.data().fileupload? then return

    $f = $fileInputs.fileupload()

    $f.on 'fileuploaddone', (event, data)=>
      new_url = data.result.avatars.cutout.url
      img = @$(event.target).closest('.vehicle-picture').find('img')
      img.attr('src', new_url)
      @vehicle.setAvatarsUrl(data.result.avatars.normal.url, data.result.avatars.cutout.url)

  serializeData: ->
    modeEdit:     @modeEditCollages
    modeOnlyList: @modeOnlyList
    iden:         @iden
    vehicle: @vehicle
