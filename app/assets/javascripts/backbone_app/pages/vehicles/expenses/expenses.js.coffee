class Pages.Vehicles.Expenses extends Backbone.Marionette.Layout
  template: 'pages/vehicles/expenses/expenses'

  regions:
    vehicle_info:       '#vehicle-info'
    maintenance_info:   '#maintenance-info'
    modification_info:  '#modification-info'
    driving_info:       '#driving-info'
    legal_info:         '#legal-info'

  events:
    'click .show-vehicle-info'       : 'showVehicleInfo'
    'click .show-maintenance-info'   : 'showMaintenanceInfo'
    'click .show-modification-info'  : 'showModificationsInfo'
    'click .show-driving-info'       : 'showDrivingInfo'
    'click .show-legal-info'         : 'showLegalInfo'

  initialize: ({@model, @currentTab})->
    @tabNames = ['vehicle', 'maintenance', 'modification', 'driving', 'legal']
    @vehicle = @model
    @user = @owner = @model.get('user')
    @currentUser = Store.get('currentUser')

  onRender: ->
#    @showBreadcrumbs(@currentTab)
    callback = =>
      @$(".vehicle-info-tabs li:not(.active .dropdown) .show-#{@currentTab}-info").trigger('click')
#      @showBreadcrumbs(@currentTab)
    setTimeout(callback, 0)

#  showBreadcrumbs: (currentTab, options=null)->
#    @breadcrumb?.show new Fragments.Breadcrumb.Index
#      collection: Collections.Breadcrumbs.forVehicle @model, currentTab, options

  setNewPath: (tab) ->
    @currentTab = tab
    Backbone.history.navigate Routers.Main.showUserExpenseTabInfoPath(@model, @currentTab), false
#    @showBreadcrumbs(tab)

  showVehicleInfo: (event) ->
    @setNewPath('vehicle')
    @vehicle_info.show new Pages.Vehicles.Expenses.VehicleInfo
      vehicle: @vehicle

  showMaintenanceInfo: ->
    @setNewPath('maintenance')
    @maintenance_info.show new Pages.Vehicles.Expenses.MaintenanceInfo
      vehicle: @vehicle

  showModificationsInfo: ->
    @setNewPath('modification')
    @vehicle.get('modifications').fetch success: (modifications) =>
      @modification_info.show new Pages.Vehicles.Expenses.ModificationInfo
        modifications: modifications

  showDrivingInfo: ->
    @setNewPath('driving')
    @track_operations = ['[+] Add More', 'EnergyTrack', 'FineTrack', 'TollTrack', 'TowingTrack', 'ParkingTrack']
    vehicleTracks = new Collections.VehicleTracks
    vehicleTracks.vehicle = @vehicle
    vehicleTracks.fetch data: {track_operations: @track_operations}, success: (vehicle_tracks) =>
      @driving_info.show new Pages.Vehicles.Expenses.DrivingInfo
        vehicle: @vehicle
        vehicle_tracks: vehicleTracks
        track_operations: @track_operations

  showLegalInfo: ->
    @setNewPath('legal')
    @track_operations = ['[+] Add More', 'InspectionTrack', 'InsuranceTrack', 'TaxTrack']
    vehicleTracks = new Collections.VehicleTracks
    vehicleTracks.vehicle = @vehicle
    vehicleTracks.fetch data: {track_operations: @track_operations}, success: (vehicle_tracks) =>
      @legal_info.show new Pages.Vehicles.Expenses.LegalInfo
        vehicle: @vehicle
        vehicle_tracks: vehicleTracks
        track_operations: @track_operations

  serializeData: ->
    user:        @user
    vehicle:     @model
    tabNames:    @tabNames
    currentTab:  @currentTab
    currentUser: @currentUser
    canManage:   @currentUser and @user.get('id') is @currentUser.get('id')