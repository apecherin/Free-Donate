#= require ./track_operations_item
class Fragments.Expenses.TrackOperations extends Backbone.Marionette.CollectionView
  template: 'fragments/vehicles/expenses/track_operations'
  itemView: Fragments.Expenses.TrackOperationsItem
  className: 'operations-container'

  initialize: ({@collection, @canEdit, @vehicle})->

  itemViewOptions: ->
    canEdit: @canEdit
    vehicle: @vehicle

  serializeData: ->
