class Pages.Galleries.Show extends Backbone.Marionette.Layout
  id: 'gallery'
  template: 'pages/galleries/show'

  regions:
    breadcrumb:    '#breadcrumb'
    galleryLayout: '#gallery-layout'
    parentTabs:    '#parent-tabs'

  events:
    'click .add-bookmark'             : 'addToBookmarks'
    'click .remove-bookmark'          : 'removeFromBookmarks'
    'click .compare'                  : 'showCompareBox'
    'click   .delete'                 : 'deleteGallery'
    'click   .edit-collages'          : 'editCollages'
    'click   .edit-collages-out'      : 'editCollagesOut'
    'click   .switch-edit-mode-input' : 'switchEditMode'
    'click   .gallery-show-tabs li'   : 'switchTab'
    'click   #title .icon-pencil'     : 'changeTitle'
    'click   #save-title'             : 'saveTitle'
    'click   #cancel-title'           : 'cancelSaveTitle'

  showCompareBox: Views.Mixins.showCompareBox
  addToBookmarks: Views.Mixins.addToBookmarks
  updateBookmarkAbilities: Views.Mixins.updateBookmarkAbilities
  removeFromBookmarks: Views.Mixins.removeFromBookmarks

  editCollages   : Views.Mixins.editCollages
  editCollagesOut: Views.Mixins.editCollagesOut
  renderCollages : Views.Mixins.renderCollages

  initialize: ({@gallery, @addPicturesList, @showPicture})->
    @pictureUrl = @gallery.get('pictures').url()
    @currentUser = Store.get('currentUser')
    @gallType = @gallery.constructor.name
    @privacy = @gallery.get('privacy')
    @is_user_profile = if (@gallType is 'Album' && Routers.Main.showUserPinsAlbumPath(@gallery) is window.location.pathname) then true else false

    @bindTo @, 'gallery:edit', @showTitleInput
    @bindTo(@gallery, 'change:title', => @renderTitle())

    @vehicle = @gallery.get('vehicle')
    if @vehicle != undefined
      @user = @vehicle.get('user')
    else
      @user = @gallery.get('user')

    @setBreadcrumbs()

    @isEditing = @gallery.justCreated is true
    @collageMode = 'collages_list'
    if @gallery.get('layout') is 'collages'
      @gallery.get('pictures').fetch()

    if @currentUser
      @bookmarkedVehicles = @currentUser.get('bookmarkedVehicles')
      if @vehicle != undefined
        @bookmarkedVehicles.onReset => @updateBookmarkAbilities()

  myyCloud: ->
    false

  onRender: ->
    @initializeFileUpload() if @canManage()

    @breadcrumb? && @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: @breadcrumbs

    unless @addPicturesList
      layout = if @collageMode == 'collages_edit' then 'collages' else @gallery.get('layout')
      @switchLayout(layout)

    if @gallType is 'Album'
      if @myyCloud()
        @parentTabs? && @parentTabs.show new Fragments.Tabs.UserCloud
          user: @gallery.get('user')
          gallery: @gallery
      else
        @parentTabs? && @parentTabs.show new Fragments.Tabs.User
          user: @gallery.get('user')
    else
      @parentTabs? && @parentTabs.show new Fragments.Tabs.Vehicle
        vehicle: @gallery.get('vehicle')

    @$('input#gallery-title').on 'keydown', (e) =>
      @keyHandler(e)

  setBreadcrumbs: ->
    @breadcrumbs = Collections.Breadcrumbs.forGallery(@gallery)

  collagesEnabled: ->
    true

  canManage: ->
    Models.Ability.canManageVehicle(@gallery.get('vehicle'))

  initializeFileUpload: ()->
    return unless @isEditing

    $fileInputs = @$('input[type=file]')
    if $fileInputs.length is 0 || $fileInputs.data().fileupload? then return

    $f = $fileInputs.fileupload()

    $f.on 'fileuploadadd', (event, data)=>
      picture = new Models.Picture
        gallery        : @gallery
        upload_progress: '0%'
      data.formData =
        client_id: picture.cid

    $f.on 'fileuploadprogress', (event, data)=>
      @gallery.get('pictures').getByCid(data.formData.client_id)
        .set upload_progress: parseInt(data.loaded / data.total * 100, 10) + '%'

    $f.on 'fileuploaddone', (event, data)=>
      pictureAttrs = data.result
      @gallery.get('pictures').getByCid(data.formData.client_id)
        .unset('upload_progress', { silent: true })
        .set(pictureAttrs)
        .initializeCreatedAt()

    $f.on 'fileuploadstart', (event, data)=>
      @$('ul.thumbnails').sortable('disable')

    $f.on 'fileuploadstop', (event, data)=>
      @gallery.get('pictures').sort()
      @$('ul.thumbnails').sortable('enable')

    if @addPicturesList?
      @galleryLayout? && @galleryLayout.show new Fragments.Galleries.Pictures
        showPicture: @showPicture
        collection: @gallery.get('pictures')
        canManage: true

      callback = =>
        @$('input[type=file]').fileupload('add', files: @addPicturesList)
        @addPicturesList = null
      setTimeout callback, 0

  showGalleries: ->
    @breadcrumbs.showGalleries()

  showPins: ->
    if @is_user_profile
      Backbone.history.navigate Routers.Main.showUserPinsPath(@user), true
    else
      tab = if @privacy is 'private' then 'priv' else 'pub'
      Backbone.history.navigate Routers.Main.myyCloudPath(tab, @user), true

  showTitleInput: ->
    callback = =>
      @$('#gallery-title').val(@gallery.get('title')).show().focus()
    setTimeout(callback, 0)

  keyHandler: (event) ->
    event.stopPropagation()
    if event.which is 13
      @saveTitle()
      event.preventDefault()

  hideTitleInputContainer: ->
    @$('#gallery-title-container').hide()

  renderTitle: ->
    @breadcrumbs.last().set('text', @gallery.get('title'))
    @$('li#title span').text(@gallery.get('title'))

  deleteGallery: ->
    bootbox.confirm(
      'Are you sure?',
      (submit)=>
        if submit
          @gallery.destroy({wait: true})
          if @gallType isnt 'Album' then @showGalleries() else @showPins()
    )
    false

  switchLayout: (layout)->
    if layout == 'collages'
      @switchCollageLayout()
    else
      @switchGridLayout()

  switchGridLayout: ->
    promise = @gallery.get('pictures').fetch()
    promise.then =>
      @galleryLayout? && @galleryLayout.show new Fragments.Galleries.Pictures
        collection: @gallery.get('pictures')
        canManage:  @canManage()
        showPicture: @showPicture

  switchCollageLayout: ->
    promise = @gallery.get('collages').fetch()
    promise.then =>
      @renderCollages(@gallery.get('collages'), @galleryLayout)

  switchTab: (e) ->
    tab = @$(e.currentTarget)
    unless tab.attr('id') in ['private', 'mosaic']
      @$('.gallery-show-tabs li').removeClass('active')
      tab.addClass('active')
      @isEditing = not @isEditing
      @$('#gallery-editing').hide()
    else
      if tab.attr('id') is 'private'
        @switchPrivacyStatus(tab)
      else
        @switchViewAs(tab)

    false

  switchViewAs: (tab) ->
    box = $(tab).find('i.gallery-mosaic-input')
    layout = if box.hasClass('icon-check') then 'grid' else 'collages'
    if box.hasClass('icon-check')
      box.removeClass('icon-check')
      box.addClass('icon-check-empty')
    else
      box.removeClass('icon-check-empty')
      box.addClass('icon-check')
    galleryAttrs =
      layout: layout
    @gallery.save galleryAttrs, wait: true, success: =>
      @switchLayout(layout)

    false

  switchPrivacyStatus: (tab) ->
    box = $(tab).find('i.gallery-privacy-input')
    privacy = ''
    if box.hasClass('icon-check')
      box.removeClass('icon-check')
      box.addClass('icon-check-empty')
      privacy = 'public'
    else
      box.removeClass('icon-check-empty')
      box.addClass('icon-check')
      privacy = 'private'
    @gallery.save(privacy: privacy)

    false

  switchEditMode: ->
    if @isEditing
      @editCollagesOut()
    @isEditing = not @isEditing
    @render()
    false

  changeTitle: (e) ->
    if @$('li#title').hasClass('active')
      @$('#gallery-title-container').show()
      @$('#gallery-title').val(@gallery.get('title'))

  saveTitle: ->
    @gallery.set title: @$('#gallery-title').val()
    @gallery.save null, wait: true
    @hideTitleInputContainer()

  cancelSaveTitle: ->
    @hideTitleInputContainer()

  serializeData: ->
    if @vehicle
      canShowSideView: Models.Ability.canShowVehicleSideView @vehicle
    pictureUrl: @pictureUrl
    canManage: @canManage()
    collagesEnabled: @collagesEnabled()
    vehicle: @vehicle
    user: @user
    privacy: @privacy
    isEditing: @canManage() && @isEditing
    isMosaic: @gallery.get('layout') is 'collages'
    canEditBookmarks: !Models.Ability.canManageVehicle @gallery.get('vehicle')
    canAddToBookmarks: !@canRemoveFromBookmarks
    canAddToOpposers: @user?.get('id') && @currentUser?.get('id') && (@user.get('id') isnt @currentUser.get('id'))
    gallType: @gallType
    gallery: @gallery