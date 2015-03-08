#= require ./maintenance_operations_item
class Fragments.Expenses.MaintenanceOperations extends Backbone.Marionette.CollectionView
  template: 'fragments/vehicles/expenses/maintenance_operations'
  itemView: Fragments.Expenses.MaintenanceOperationsItem
  className: 'operations-container'

  initialize: ({@collection, @canEdit, @vehicle, @service_attributes})->

  itemViewOptions: ->
    canEdit: @canEdit
    vehicle: @vehicle
    service_attributes: @service_attributes

  serializeData: ->
