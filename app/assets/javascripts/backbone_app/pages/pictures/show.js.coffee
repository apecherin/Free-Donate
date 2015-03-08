class Pages.Pictures.Show extends Backbone.Marionette.Layout
  template:  'pages/pictures/show'
  className: 'gallery view-picture modal'

  regions:
    thumbScroller: '.thumb-scroller'
    comments     : '.picture-comments'
    vote         : '#vote-container'

  triggers:
    'click .prev-picture' : 'nav:prev'
    'click .next-picture' : 'nav:next'

  events:
    'click .crop-cutout'  : 'cropCutout'
    'click .edit-image'   : 'editImage'
    'click .remove-blurs' : 'removeBlurs'
    'click .rotate-left'  : 'rotateLeft'
    'click .rotate-right' : 'rotateRight'
    'click .edit-info'    : 'editInfo'
    'click .set-as-cover' : 'setAsGalleryCoverPicture'
    'click .delete'       : 'deletePicture'
    'click .picture-image': 'clickHandler'
    'click .toggle-full'  : 'toggleFullScreen'
    'click .picture-info .close' : 'closeModal'

  modalKeyboard: false

  initialize: ({@picture, @pictures, @modification, @cutout})->
    @modification = if @modification? then @modification else null
    @model = @modelNext = @modelPrev =  @picture
    @album = @model instanceof Models.ProfileAlbumPicture

    @is_user_profile = if (@album && Routers.Main.showUserPinsAlbumPicturePath(@model) is window.location.pathname) then true else false
    @modelCollection = @pictures || @model.get('gallery').get('pictures')
    @bindModel()

    comparator = (item)=> item.get('id')
    @modelCollection.comparator= comparator
    @modelCollection.sort()
    @counter =
      current : => @currentCounter()
      total   : @modelCollection.size()

    @layout =
      fullScreen     : false
      mode           : if @cutout? then 'cutouts_new' else 'pictures_show'
      topBarHeight   : 30
      topBar2Height  : 126
      bottomBarHeight: 58

    @bindTo @, 'before:render', @calculateLayout
    @bindTo(@, 'nav:prev', => @prevPicture())
    @bindTo(@, 'nav:next', => @nextPicture())
    @bindTo(MyApp.vent, 'picture:jump:to', @jumpToPicture)

    $(document).on 'keydown', => @keyHandler(event)

    @bindTo @, 'item:before:close', =>
      $(document).off 'keydown'
      @model.set('comments_size', @model.get('comments').size())
      @$el.parent().removeClass('fullscreen')

  closeModal: ->
    @returnToCollection()

  returnAfterRemove: ->
    if @cutout?
      return false
    if @model.constructorName? && @model.constructorName in ['part_purchase_picture', 'service_picture']
      tab = if @model.constructorName is 'part_purchase_picture' then 'parts' else 'services'
      Backbone.history.navigate Routers.Main.showModificationsConfDomainModCPSPath(@modification.get('vehicle'), @modification.get('change_set'), @modification.get('domain'), @modification, tab), true
    else
      if @album
        if @is_user_profile
          Backbone.history.navigate Routers.Main.showUserPinsAlbumPath(@model.get('album')), true
        else
          album = @model.get('album')
          user = @model.get('user')
          Backbone.history.navigate Routers.Main.showUserAlbumPath(user, album), false
      else
        gallery = @model.get('gallery')
        Backbone.history.navigate Routers.Main.showVehicleGalleryPath(gallery, gallery.get('vehicle')), true

  returnToCollection: ->
    if @cutout?
      return false
    @model.fetch wait: true, success:(model) =>
      if @model.constructorName? && @model.constructorName in ['part_purchase_picture', 'service_picture']
        tab = if @model.constructorName is 'part_purchase_picture' then 'parts' else 'services'
        Backbone.history.navigate Routers.Main.showModificationsConfDomainModCPSPath(@modification.get('vehicle'), @modification.get('change_set'), @modification.get('domain'), @modification, tab), true
      else
        if @album
          if @is_user_profile
            Backbone.history.navigate Routers.Main.showUserPinsAlbumPath(model.get('album')), true
          else
            album = model.get('album')
            user = model.get('user')
            console.log "PATH- #{Routers.Main.showUserAlbumPath(user, album)}"
            Backbone.history.navigate Routers.Main.showUserAlbumPath(user, album), true
        else
          gallery = model.get('gallery')
          Backbone.history.navigate Routers.Main.showVehicleGalleryPath(gallery, gallery.get('vehicle')), true

  bindModel: ->
    @bindTo @model, 'change:title', => @render()
    @bindTo @model, 'change:created_at', => @render()

  unbindModel: ->
    @model.unbind 'change:title'
    @model.unbind 'change:created_at'

  onRender: ->
    @setPrevNext()

    if @layout.fullScreen
      @$el.parent().addClass('fullscreen')
    else
      @$el.parent().removeClass('fullscreen')
      if @layout.mode == 'pictures_show'
        @comments? && @comments.show(new Fragments.Pictures.Comments(picture: @model, layout: @layout))

    if @thumbScroller?
      callback = => @showThumbScroller()
      setTimeout(callback, 0)

    if @album
      @$('.btn-toolbar .btn').hide()
      @$('.btn-toolbar .profile-picture-action.btn').show()

    if @model.constructorName? && @model.constructorName in ['part_purchase_picture', 'service_picture']
      @$('.btn-toolbar .btn').hide()

    @model.fetch wait: true, success:(picture) =>
      @vote? && @vote.show new Fragments.Pictures.Vote(picture: picture)

  calculateLayout: ->
    if @layout.fullScreen
      _.extend @layout,
        commentsWidth: 0
        marginWidth  : 0
        marginHeight : 0
    else
      _.extend @layout,
        commentsWidth: if @layout.mode == 'pictures_show' then 300 else 0
        marginWidth  : 20
        marginHeight : 20

    @layout.pictureMaxWidth = Math.max(640, $(window).width() - @layout.commentsWidth - @layout.marginWidth)
    @layout.commentsHeight = Math.max(520, $(window).height() - @layout.bottomBarHeight - @layout.marginHeight)
    @layout.pictureMaxHeight = @layout.commentsHeight + @layout.bottomBarHeight
    @model.scaleToLimit(@layout.pictureMaxWidth, @layout.pictureMaxHeight)

  toggleFullScreen: ->
    @layout.fullScreen = !@layout.fullScreen
    @render()
    false

  showThumbScroller: ->
    @scrollerWidth = @layout.pictureMaxWidth - 102
    @$('.thumb-scroller-wrapper').css('width', @scrollerWidth)

    view = new Fragments.Pictures.ThumbScroller(collection: @modelCollection, currentPicture: @model)
    @bindTo(view, 'after:render', =>
      @$('.thumb-scroller-wrapper').thumbnailScroller()

      fullScrollerWidth = @$('.thumb-scroller').width()
      if fullScrollerWidth > @scrollerWidth
        @$('.thumb-scroller > div').css('left', (@scrollerWidth - fullScrollerWidth) * @counter.current() / @counter.total)
      @$('.picture-bar').css('visibility', 'visible')
    )
    @thumbScroller? && @thumbScroller.show(view)

  setPrevNext: ->
    index = @modelCollection.indexOf(@model)

    # traverse collection in reverse order
    if index > 0
      @modelNext = @modelCollection.at(index - 1)
    else
      @modelNext = @modelCollection.last()

    if index < @modelCollection.size() - 1
      @modelPrev = @modelCollection.at(index + 1)
    else
      @modelPrev = @modelCollection.first()

  currentCounter: ->
    @counter.total - @modelCollection.indexOf(@model)

  prevPicture: ->
    @jumpToPicture @modelPrev

  nextPicture: ->
    @jumpToPicture @modelNext

  jumpToPicture: (picture)->
    console.log picture
    unless @cutout?
      if @model.constructorName? && @model.constructorName in ['part_purchase_picture', 'service_picture']
        tab = if @model.constructorName is 'part_purchase_picture' then 'parts' else 'services'
        Backbone.history.navigate Routers.Main.showModificationsConfDomainModPicPath(@modification.get('vehicle'), @modification.get('change_set'), @modification.get('domain'), @modification, picture, tab)
      else
        picture.setPictureUrl()
    @unbindModel()
    @model = picture
    @bindModel()
    @render()

  cropCutout: ->
    MyApp.modal.show new Modals.Collages.CutoutsNew
      picture: @model
      pictures: @modelCollection
      cutout: @cutout
    false

  editImage: ->
    modal = new Pages.Pictures.EditImage(picture: @model)
    MyApp.modal.show(modal)
    false

  removeBlurs: ->
    @savePicture {unblur: 'all'}, =>
      @model.set('unblur', null)

  savePicture: (pictureAttrs, callback)->
    @model.set pictureAttrs
    @model.save(null, {wait: true}).done =>
      callback()
      @model.trigger('change:title')
    false

  rotateLeft: ->
    @rotate('left')

  rotateRight: ->
    @rotate('right')

  rotate: (direction)->
    @$('.picture-image').css('overflow', 'hidden')

    @model.swapDimensions()
    maxWidth = $(window).width()
    maxHeight = $(window).height()
    @model.scaleToLimit(maxWidth, maxHeight)

#    @render()

    scaleX = @model.bigWidth / @model.bigHeight
    scaleY = 1 / scaleX

    angle = if direction == 'left' then '-90deg' else '90deg'

    $image = @$('.picture-image img')
    $image.css('-webkit-transform', "scaleX(#{scaleX}) scaleY(#{scaleY}) rotate(#{angle})")
    $image.css('-moz-transform', "scaleX(#{scaleX}) scaleY(#{scaleY}) rotate(#{angle})")
    $image.css('-ms-transform', "scaleX(#{scaleX}) scaleY(#{scaleY}) rotate(#{angle})")
    $image.css('-o-transform', "scaleX(#{scaleX}) scaleY(#{scaleY}) rotate(#{angle})")
    $image.css('transform', "scaleX(#{scaleX}) scaleY(#{scaleY}) rotate(#{angle})")

    @savePicture {rotate: direction}, =>
      @model.set('rotate', null)
    false

  editInfo: ->
    modal = new Modals.Pictures.Edit(picture: @model)
    MyApp.innerModal.show(modal)
    @disableKeyHandler(modal)
    false

  setAsGalleryCoverPicture: ->
    gallery = @model.get('gallery')
    return false unless gallery
    gallery.save({ cover_picture_id: @model.id }, wait: true)
    false

  deletePicture: ->
    bootbox.confirm 'Are you sure?', (submit)=>
      if submit
        pictures = @modelCollection
#        if @album
        @model.destroy
          sex: 'ffff'
          wait: true
          success: ()->
            pictures.fetch()
        @close()
        @returnAfterRemove()
    false

  removeAlbumPicture: ->


  disableKeyHandler: (modal)->
    $(document).off 'keydown'
    @bindTo(modal, 'close', =>
      $(document).on 'keydown', => @keyHandler(event)
    )

  keyHandler: (event)->
    switch event.which
      when 37 # left arrow
        event.preventDefault()
        @prevPicture()
      when 39 # right arrow
        event.preventDefault()
        @nextPicture()
      when 27 # escape
        @returnToCollection()
        event.preventDefault()
        if @layout.fullScreen
          @toggleFullScreen()
        else
          @close()

  clickHandler: (event)->
    body = @$('.modal-body')
    if (event.pageX - body.offset().left) / body.width() < 0.5
      @prevPicture()
    else
      @nextPicture()

  serializeData: ->
    layout:  @layout
    picture: @model
    counter: @counter
    canManage: Models.Ability.canManagePicture(@model)