class Pages.Vehicles.Expenses.MaintenanceInfo extends Backbone.Marionette.Layout
  template: 'pages/vehicles/expenses/tab_info/maintenance_info'

  events:
    'click .add-operation' : 'addOperation'

  regions:
    'maintenanceOperations' : '#maintenance-operations'

  initialize: ({@vehicle})->
    @currentUser = Store.get('currentUser')
    @user = @vehicle.get('user')
    @canEdit = @currentUser && @user.id is @currentUser.id
    @maintenance_operations = @vehicle.get('maintenance_operations')
    @totalCostParts = @maintenance_operations.pluck("parts_cost")
    @totalCostManHours = @maintenance_operations.pluck("man_hours_cost")
    @currentCurrencyRate = Store.get('current_currency_rate')
    @bindTo MyApp.vent, 'maintenance_operations:item_removed', @updateMaintenanceOperationList
    @bindTo MyApp.vent, 'maintenance_operations:update_items', @updateMaintenanceOperationList

  onRender: ->
    @serviceAttributes = new Models.ServiceAttributes
    @serviceAttributes.fetch wait: true, success: (service_attributes)=>
      @maintenanceOperations.show new Fragments.Expenses.MaintenanceOperations
        collection: @vehicle.get('maintenance_operations')
        canEdit: @canEdit
        vehicle: @vehicle
        service_attributes: service_attributes

  updateMaintenanceOperationList: ->
    @maintenance_operations.vehicle = @vehicle
    @maintenance_operations.fetch wait: true, success: (maintenance_operations)=>
      @totalCostParts = maintenance_operations.pluck("parts_cost")
      @totalCostManHours = maintenance_operations.pluck("man_hours_cost")
      @render()

  addOperation: ->
#    @$('.add-operation').addClass 'disable-operations-actions'
    @maintenance_operations.add new Models.MaintenanceOperation
    false

  serializeData: ->
    totalCostParts: @totalCostParts
    totalCostManHours: @totalCostManHours
    currentCurrencyRate: @currentCurrencyRate
    canEdit: @canEdit