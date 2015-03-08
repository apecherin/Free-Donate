#= require ./change_set_tab_content_items
#= require ./change_set_tab_nav_items

class Pages.Vehicles.Modifications.Dashboard extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/dashboard'
  id: 'modifications-dashboard'

  regions:
    changeSetsContentItems: '#change-set-tab-content-items'
    changeSetsNavItems:     '#change-set-tab-nav-items'

  initialize: ({@vehicle, @parts, @vendors, @currentChangeSet, @currentDomainName, @currentModificationId, @currentPurchasePictureId, @cps_tab})->
    @changeSets = @vehicle.get 'change_sets'
    @currentChangeSet = if @currentChangeSet? then @currentChangeSet else null
    @currentDomainName = if @currentDomainName? then @currentDomainName else null
    @currentModificationId = if @currentModificationId? then @currentModificationId else null
    @currentPurchasePictureId = if @currentPurchasePictureId? then @currentPurchasePictureId else null
    @bindTo MyApp.vent, 'change_set:removed', @showCurrentChangeSet

  onRender: ->
    changeSetNavItemsView = new Pages.Vehicles.Modifications.ChangeSetTabNavItems collection: @changeSets, vehicle: @vehicle

    @bindTo changeSetNavItemsView, 'composite:collection:rendered', =>
      @bindTo changeSetNavItemsView, 'item:added', (changeSetView)=>
        @activateChangeSetTab changeSetView.model
      @bindTo changeSetNavItemsView, 'item:removed', =>
        if @changeSets.length
          @activateChangeSetTab @changeSets.first()

    @vehicle.get('version').get('properties').fetch
      success: (properties)=>
        @changeSetsNavItems.show changeSetNavItemsView
        @changeSetsContentItems.show new Pages.Vehicles.Modifications.ChangeSetTabContentItems
          collection: @changeSets
          versionProperties: properties
          currentChangeSet: @currentChangeSet
          currentDomainName: @currentDomainName
          currentModificationId: @currentModificationId
          currentPurchasePictureId: @currentPurchasePictureId
          cps_tab: @cps_tab
        if @changeSets.length
          @activateChangeSetTab @changeSets.first()
          if @currentChangeSet?
            @activateChangeSetTab @currentChangeSet

        @currentChangeSet = @currentDomainName = @currentModificationId = @currentPurchasePictureId = @cps_tab = null

  activateChangeSetTab: (changeSet)->
    _.defer =>
      href = HAML.globals()['domId'](changeSet)
      @$("a[href='##{href}']").tab('show')

  showCurrentChangeSet: () ->
    @vehicle.get('change_sets').fetch success: (change_sets) =>
      if change_sets.length
        options = {}
        options['change_set'] = change_sets.first()
        @activateChangeSetTab change_sets.first()
        MyApp.vent.trigger 'change_set:choice', 'modifications', options
        Backbone.history.navigate Routers.Main.showModificationsConfPath(@vehicle, change_sets.first())
      else
        MyApp.vent.trigger 'change_set:choice', 'modifications', null
        Backbone.history.navigate "#{Routers.Main.showNewVehiclePath @vehicle}/modi"

  serializeData: ->
    vehicle: @vehicle
    changeSets: @changeSets
    is_owner: Models.Ability.canManageVehicle(@vehicle)
