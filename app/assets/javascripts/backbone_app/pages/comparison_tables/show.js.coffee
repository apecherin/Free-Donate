class Pages.ComparisonTables.Show extends Backbone.Marionette.Layout
  className: 'comparison_tables'
  template: 'pages/comparison_tables/show'

  regions:
    'breadcrumb' : '#breadcrumb'
    'socialActions'    : '#social-actions'

  events:
    'click #save-title'                   : 'submitTitle'
    'click #change-title-cancel'          : 'hideTitleInput'
    'change input.change-set'             : 'toggleProperties'
    'change input.toggle-show-properties' : 'toggleShowProperties'
    'click .remove-vehicle'               : 'removeVehicle'
    'click .vehicle-link'                 : 'goToVehicleIdentification'
    'click .tab-switch'                   : 'activateNewTab'
    'click .add-opposer'                  : 'addToUserOpposers'
    'click .comparison-table-liker-saver-username-link' : 'goToUserProfile'
    'click .edit-avatar'                  : 'goToUserWall'
    'click #user-information'             : 'showUserInfo'
    'click .bubble-comment-avatar-img' : 'goToUserProfile'
    'click .bubble-comment-amt-comments-link' : 'goToCommentsPage'

  initialize: ({@model, @pairId})->
    @pairId = if @pairId? then @pairId else null
    @bindTo(@model, 'change:title', => @renderTitle())

    @canManage = Models.Ability.canManageComparisonTable(@model)
    @vehicles = @model.get('vehicles')
    @hiddenChangeSetIds = []
    @currentTab = 'performance_comparison_attributes_set'
    @currentSubTab = 'likers'
    @currentUser = Store.get('currentUser')
    @modelUser = @model.get('user')

    @maxCommentsToDisplay = 3
    @sideViews = []

    for vehicle in @model.get('vehicles').models
      if vehicle.get('side_view')
        @sideViews.push vehicle.get('side_view')
        break if @sideViews.length is @maxSideViewsToDisplay

  onRender: ->
    _.defer =>
        @activateTab()
        @showTooltips()
        @renderVehicleSideViews()
    @socialActions.show new Fragments.Comparisons.SocialActions
      comparisonTable: @model
      currentUser: @currentUser
      modelUser: @modelUser
    @setBreadcrumbs()
    @$('input#comparison-title').on 'keydown', (e) =>
      @keyHandler(e)

    @$('.bubble-comment-avatar').popover('show')

  setBreadcrumbs: ->
    title = @model.get('label') || I18n.t('untitled_comparison', scope: 'ui')
    @breadcrumbs = Collections.Breadcrumbs.forComparisons(@modelUser, title)
    if @canManage
      @breadcrumbs.models.last().set
        editable: true,
        callback: _.bind(@showTitleInput, this)
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: @breadcrumbs

  activateTab: ->
    callbacks = =>
      $tab = @$("a[href=##{@currentTab}]")
      $tab.tab 'show'
      if $tab.hasClass('has-subtabs')
        @$("a[href=##{@currentSubTab}]").tab 'show'
      @$('.bar-data').filter(':visible').each (i, el) =>
        right = parseInt($(el).css('right'), 10)
        height = $(el).height()
        width = $(el).width()
        if right + width >= 625
          offset = right + width - 625
          $(el).css(right: "#{right - offset}px")
          $vehicleImg = $(el).closest('.vehicle-row').find('.vehicle-link')
          imgLeft = parseInt($vehicleImg.css('left'), 10)
          $vehicleImg.css(left: "#{imgLeft + offset}px")

    setTimeout callbacks, 0

  activateNewTab: (e) ->
    $target = $(e.currentTarget)
    tabName = $target.data('tab-name')
    isSubTab = $target.hasClass('is-subtab')
    if isSubTab
      @currentSubTab = tabName
    else
      @currentTab = tabName
    @activateTab()
    e.preventDefault()

  addToUserOpposers: ->
    bootbox.confirm(
      "Are you sure to block <strong>#{@model.get('user').get('username')}</strong> permanently?",
      (submit) =>
        if submit
          userOpposition = new Models.UserOpposition
          userOpposition.set opposer_id: @model.get('user').id
          userOpposition.save null, wait: true
    )
    false

  goToUserProfile: (e) ->
    $target = $(e.currentTarget)
    userId = $target.data('user-id')
    path = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate path, true
    false

  goToCommentsPage: (e) ->
    vehicleId = $(e.currentTarget).data('vehicle-id')
    vehicle = new Models.Vehicle({id: vehicleId})
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      Backbone.history.navigate(
        Routers.Main.showVehicleCommentsPath(vehicle),
        true
      )
    false

  goToUserWall: (e) ->
    $target = $(e.currentTarget)
    userId = $target.data('user-id')
    path = Routers.Main.showUserProfileWallsPath(userId)
    Backbone.history.navigate path, true
    false

  showTooltips: ->
    @$('.vehicle-row-img').tooltip()

  correctVehicleSideView: (img) ->
    sideViewMaxWidth = 110
    $img = $(img)
    width = $img.width()
    return if width <= sideViewMaxWidth
    moveLeft = width - sideViewMaxWidth
    $img.css(right: "#{moveLeft}px")

  renderVehicleSideViews: ->
    @$('.vehicle-side-view img').each (i, img) =>
      $img = $(img)
      width = $img.width()
      if width > 0
        this.correctVehicleSideView($img)
      else
        $img.load =>
          this.correctVehicleSideView($img)
          false

  toggleProperties: (e) ->
#    return false unless @canManage
    $target = $(e.target)
    @model.set {selected_change_set_ids: @collectSelectedChangeSetIds()}
    @render()
#    @model.save {selected_change_set_ids: @collectSelectedChangeSetIds()}, success: =>
#      @render()

  toggleShowProperties: (e) ->
#    return false if @canManage
    $target = $(e.target)
    @showOrHidePropertiesForChangeSet($target.val())

  showOrHidePropertiesForChangeSet: (changeSetId) ->
    if _.include(@hiddenChangeSetIds, changeSetId.toString())
      @hiddenChangeSetIds = _.reject @hiddenChangeSetIds, (id) ->
        id.toString() is changeSetId.toString()
    else
      @hiddenChangeSetIds.push(changeSetId.toString())
    @render()

  goToVehicleIdentification: (e) ->
    $target = $(e.currentTarget)
    vehicleId = $target.data('vehicle-id')
    vehicle = @vehicles.get(vehicleId)
    return false unless vehicle
    vehicle.set({user: @model.get('user')})
    Backbone.history.navigate Routers.Main.showVehicleIdentificationPath(vehicle), true
    false

  collectSelectedChangeSetIds: ->
    @$("input.change-set:checked").serializeArray().map (e)->
      e.value

  removeVehicle: (e) ->
    return false unless @canManage
    @vehicles.remove $(e.target).data 'id'
    @model.save {}, success: =>
      @render()
    false

  getUserLikes: ->
    @model.get('likers')

  showTitleInput: ->
    callback = =>
      @$('.comparisons-title').show()
      @$('#comparison-title').val(@model.get('label')).focus()
    setTimeout(callback, 0)

  submitTitle: (event)->
    @updateTitle()

    false

  updateTitle: ->
    @model.set label: @$('#comparison-title').val()
    @model.save null, wait: true
    @hideTitleInput()

  hideTitleInput: ->
    @$('.comparisons-title').hide()
    @renderTitle()

    false

  renderTitle: ->
    @breadcrumbs.last().set('text', @model.get('label'))

  showUserInfo: ->
    if @currentUser?
      @model.get('user').fetch success: (user) =>
        MyApp.modal.show new Modals.Users.UserInfo
          user: user
          current_user: @currentUser
          user_ratings: user.get('ratings')
          user_oppositions: @currentUser.get('user_oppositions')
    false

  keyHandler: (event) ->
    event.stopPropagation()
    if event.which is 13
      @updateTitle()
      event.preventDefault()

  serializeData: ->
    checkAllChangeSets =
    if @canManage
      @model.get('selected_change_set_ids') is null || @model.get('selected_change_set_ids').length is 0
    else
      false
    selected = @model.get('selected_change_set_ids')
    if selected is null
      selected = _.flatten(@vehicles.map (v) -> v.get('change_sets').map (change) -> change.id)
    selectedChangeSetIds =
    if @canManage
      selected
    else
      _.reject selected, (id) =>
        _.include(@hiddenChangeSetIds, id.toString())

    comparisonTable:         @model
    canManage:               @canManage
    vehicles:                @vehicles
    comparisonAttributes:    @model.get 'comparison_attributes'
    propertyValuesHash:      @model.get 'properties'
    checkAllChangeSets:      checkAllChangeSets
    selectedChangeSetIds:    selectedChangeSetIds.map (id) -> id.toString()
    user: @model.get('user')
    canAddToOpposers: Models.Ability.canAddToOpposers(@model.get('user'))
    likers: @model.get('likers')
    savers: @model.get('savers')