# The page to show a vehicle.
# This page display few components
#   - A title of the vehicle: the label of the brand and the model.
#   - A picture to illustrate the vehicle.
#   - A block of "quick information".
#   - A tabs container.
#
class Pages.Vehicles.Show extends Backbone.Marionette.Layout

  template: 'pages/vehicles/show'

  # Some tab-content blocks may be used as regions.
  regions:
    breadcrumb:          '#breadcrumb'
    identification:      '#identification'
    identification_show: '#identification_show'
    avatar:              '#avatar'
    galleries:           '#galleries'
    specifications:      '#specifications'
    expenses:            '#expenses'
    modifications:       '#modifications'
    performances:        '#performances'
    version_comments:    '#version_comments'
    silhouette:          '#silhouette'
    follow_to_user:      '.follow-to-user'
    follow_to_vehicle:   '.follow-to-vehicle'
    compare_vehicle:     '.compare-vehicle'

  events:
    'click .add-bookmark'        : 'addToBookmarks'
    'click .remove-bookmark'     : 'removeFromBookmarks'
    'click .compare'             : 'showCompareBox'

    'click .delete-vehicle'      : 'deleteVehicle'
    'click .change_side_view'    : 'showSilhTab'

    'show a.show-identification'      : 'showIdentificationEditTab'
    'show a.show-identification_show' : 'showIdentificationShowTab'
    'show a.show-galleries'      : 'showGalleriesTab'
    'show a.show-specifications' : 'showSpecificationsTab'
    'show a.show-expenses'       : 'showExpensesTab'
    'show a.show-modifications'  : 'showModificationsTab'
    'show a.show-performances'   : 'showPerformancesTab'
    'show a.show-version_comments' : 'showCommentsTab'
    'show a.show-silhouette'     : 'showSilhTab'
    'click .disabled'            : 'stopPropagation'
    'click #user-information'    : 'showUserInfo'

  showCompareBox: Views.Mixins.showCompareBox
  addToBookmarks: Views.Mixins.addToBookmarks
  updateBookmarkAbilities: Views.Mixins.updateBookmarkAbilities
  removeFromBookmarks: Views.Mixins.removeFromBookmarks

  initialize: ({@currentTab, @changeSetId, @domainName, @modificationId, @cps_tab, @partPurchasePictureId, @currentExpenTab})->
    @tabNames     = ['galleries', 'performances', 'modifications', 'specifications', 'expenses', 'identification_show', 'identification', 'version_comments', 'silhouette']

    # these tabs appear alone, without the other tabs
    @soloTabNames = ['version_comments']

    @currentExpenTab = if @currentExpenTab? then @currentExpenTab else 'vehicle'

    # these attrs is specific for modifications tab
    @changeSetId = if @changeSetId? then @changeSetId else null
    @domainName = if @domainName? then @domainName else null
    @modificationId = if @modificationId? then @modificationId else null
    @partPurchasePictureId = if @partPurchasePictureId? then @partPurchasePictureId else null

    @vehicle = @model
    @replaceHistoryState = !@currentTab
    @currentTab ||= 'identification'
    @owner = @user =  @model.get('user')
    @currentUser = Store.get('currentUser')

    @bindTo @model, 'change:side_view', => @render()
    @bindTo MyApp.vent, 'change_set:choice', @showBreadcrumbs
    @bindTo MyApp.vent, 'domain:choice', @showBreadcrumbs
    @bindTo MyApp.vent, 'modification:choice', @showBreadcrumbs
    @bindTo MyApp.vent, 'cps_tab:choice', @showBreadcrumbs

  onRender: ->
    @showBreadcrumbs(@currentTab)
    callback = =>
      @$("li:not(.active .dropdown) a.show-#{@currentTab}").last().trigger('click')
      @showBreadcrumbs(@currentTab)
    hideAndShowBreadcrumbs = =>
      MyApp.vent.trigger 'model_name_available:changed'
      @breadcrumb?.close()
      @showBreadcrumbs(@currentTab)

    @model.get('version').on('change:show_model_name', hideAndShowBreadcrumbs)
    @model.get('version').on('change:second_name', hideAndShowBreadcrumbs)
    setTimeout(callback, 0)

    @follow_to_user?.show new Fragments.Users.Profile.Follow model: @owner, followings: new Collections.Followings, buttonLabel: @owner.get('username').toLowerCase().capitalize()
    @follow_to_vehicle?.show new Fragments.Vehicles.FavoriteButton vehicle: @vehicle, vehicleType: @vehicle.get('type')
    @compare_vehicle?.show new Fragments.Vehicles.SaveComparisonButton vehicle: @vehicle

  showUserInfo: ->
    if @currentUser?
      @model.get('user').fetch success: (user) =>
        MyApp.modal.show new Modals.Users.UserInfo
          user: user
          current_user: @currentUser
          user_ratings: user.get('ratings')
          user_oppositions: @currentUser.get('user_oppositions')
    false

  onClose: ->
    @model?.get('version').off('change:show_model_name')
    @model?.get('version').off('change:second_name')

  showBreadcrumbs: (currentTab, options=null)->
    @breadcrumb?.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forVehicle @model, currentTab, options

  stopPropagation: ->
    false

  deleteVehicle: ->
    bootbox.confirm  'Are you sure?', (submit) =>
      if submit
        redirectPath = Routers.Main.showUserVehiclesPath(@model.get('user'))
        promise = @model.destroy wait: true
        promise.done -> Backbone.history.navigate redirectPath, true
    false

  showIdentificationShowTab: ->
    @showBreadcrumbs('identification')
    $vehicleTabs = $('.vehicle-tabs')
    $vehicleTabs.find('.show-identification').closest('li').hide()
    $vehicleTabs.find('.show-identification_show').closest('li').show()
    @showIdentificationTab Routers.Main.showVehicleIdentificationPath(@model), (attrs) =>
      @identification_show.show new Fragments.Vehicles.IdentificationShow(attrs)

  showIdentificationEditTab: ->
    @showBreadcrumbs('identification')
    $vehicleTabs = $('.vehicle-tabs')
    $vehicleTabs.find('.show-identification_show').closest('li').hide()
    $vehicleTabs.find('.show-identification').closest('li').show()
    @showIdentificationTab Routers.Main.showVehicleIdentificationEditPath(@model), (attrs) =>
      @identification.show new Fragments.Vehicles.Identification(attrs)

  showIdentificationTab: (navPath, callback) ->
    @showBreadcrumbs('identification')
    if @replaceHistoryState
      Backbone.history.navigate(navPath, replace: true)
    else
      Backbone.history.navigate(navPath)
    @model.get('version').fetch success: (version) =>
      versionAttributes = new Models.VersionAttributes version: version
      versionAttributes.fetch success: (versionAttributes) =>
        @model.get('ownership').fetch success: =>
          generations = new Collections.Generations
          generations.version = version
          generations.fetch success: (generations) =>
            callback(
              model: @model
              version: @model.get('version')
              ownership: @model.get('ownership')
              versionAttributes: versionAttributes
              generations: generations
            )

  showGalleriesTab: ->
    @showBreadcrumbs('galleries')
    galleries = @model.get('galleries')
    galleries.fetch success: (galleries) =>
      Backbone.history.navigate Routers.Main.showUserVehiclePath(@owner, @model)
      @galleries.show new Fragments.Vehicles.Galleries
        model: @model
        collection: galleries

  showPerformancesTab: ->
    @showBreadcrumbs('performances')
    Backbone.history.navigate "#{Routers.Main.showNewVehiclePath @model}/perf"
    @model.get('version').fetch success: (version, response) =>
      version.get('data_sheet').fetch success: (dataSheet, response) =>
        @model.currentChengeSet().fetch success: (current_change_set) =>
          @performances.show new Fragments.Vehicles.Performances.Show
            version:            version
            dataSheet:          dataSheet
            vehicle:            @model
            current_change_set: current_change_set
            modifications:      current_change_set.get('modifications')

  showSpecificationsTab: ->
    @showBreadcrumbs('specifications')
    Backbone.history.navigate "#{Routers.Main.showNewVehiclePath @model}/spec"
    @model.get('version').fetch success: (version, response) =>
      version.get('data_sheet').fetch success: (dataSheet, response) =>
        @model.currentChengeSet().fetch success: (current_change_set) =>
          callback = (importToolAvailable, modelDataSheets) =>
            @specifications.show new Fragments.Vehicles.Specifications.Show
              version:             version
              dataSheet:           dataSheet
              vehicle:             @model
              modifications:       current_change_set.get('modifications')
              importToolAvailable: importToolAvailable
              dataSheets:          modelDataSheets

          if ! _.any(dataSheet['attributes'], (attrs, name) => attrs?['value']?)
            dataSheets = new Collections.DataSheets()
            dataSheets.m_id =  @model.get('model').id
            dataSheets.fetch success: (datasheets, response) =>
              callback(true, datasheets)
          else
            callback(false, [])

  showCommentsTab: ->
    @showBreadcrumbs('version_comments')
    version = @model.get('version')
    version.set('vehicle', @model)
    comments = new Collections.PrewrittenVersionCommentsWithUsers()
    comments.version =  version
    promise = comments.fetch()
    promise.done =>
      comments.each (comment) ->
        comment.set('canManage', Models.Ability.canManageVehicle(version.get('vehicle')))
      @version_comments.show new Fragments.Vehicles.VersionComments
        model:      version
        collection: comments

  showExpensesTab: ->
    @showBreadcrumbs('expenses')
    @expenses.show new Pages.Vehicles.Expenses
      model: @model
      currentTab: @currentExpenTab

  showModificationsTab: ->
    console.log 'showModificationsTab'
    @model.get('change_sets').fetch success: (change_sets) =>
      if change_sets.size() > 0
        options = {}
        current_change_set = change_sets.first()
        if @model.get('current_change_set_id')?
          current_change_set = change_sets.find (change_set) => change_set.id is @model.get('current_change_set_id')
        if @changeSetId?
          current_change_set = change_sets.find (change_set) => change_set.id is @changeSetId.toNumber()

        if current_change_set?
          @modifications.show new Pages.Vehicles.Modifications.Dashboard
            vehicle: @model
            currentChangeSet: current_change_set
            currentDomainName: @domainName
            currentModificationId: @modificationId
            currentPurchasePictureId: @partPurchasePictureId
            cps_tab: @cps_tab

          if !@domainName? || !@modificationId?
            options['change_set'] = current_change_set
            @showBreadcrumbs('modifications', options)

          @domainName = @modificationId = @cps_tab = @partPurchasePictureId = null
        else
          @modifications.show new Pages.Vehicles.Modifications.Dashboard vehicle: @model
          @showBreadcrumbs('modifications')
          Backbone.history.navigate "#{Routers.Main.showNewVehiclePath @model}/modi"

        unless @changeSetId?
          Backbone.history.navigate Routers.Main.showModificationsConfPath(@model, current_change_set)
      else
        @modifications.show new Pages.Vehicles.Modifications.Dashboard vehicle: @model
        @showBreadcrumbs('modifications')
        Backbone.history.navigate "#{Routers.Main.showNewVehiclePath @model}/modi"

      @changeSetId = @partPurchasePictureId = @modificationId = @domainName = null
#    false

  showSilhTab: ->
    if Models.Ability.canManageVehicle(@model) and @currentUser
      @showBreadcrumbs('silhouette')
      Backbone.history.navigate "#{Routers.Main.showNewVehiclePath @model}/edit/silh"
      if @model.get('side_view') is null
        @model.set('side_view', new Models.SideView())
      side_views = new Collections.SideViews()
      side_views.fetch
        data:
          version_id: @model.get('version').id
        wait: true
        success: (side_views)=>
          @silhouette.show new Fragments.Vehicles.SilhouetteShow
            model:      @model.get('side_view')
            vehicle:    @model
            side_views: side_views

  serializeData: ->
    vehicle:           @model
    canEditBookmarks:  !Models.Ability.canManageVehicle(@model) and @currentUser
    canAddToBookmarks: !@canRemoveFromBookmarks
    tabNames:          @tabNames
    soloTabNames:      @soloTabNames
    currentTab:        @currentTab
    user:              @user
    canAddToOpposers:  @currentUser and @user.get('id') isnt @currentUser.get('id')
    canManage:         @currentUser and @user.get('id') is @currentUser.get('id')
    currentUser:       @currentUser
