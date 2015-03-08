#= require ./modifications_item
class Fragments.Expenses.Modifications extends Backbone.Marionette.CollectionView
  itemView: Fragments.Expenses.ModificationsItem
  className: 'modifications-container'

  initialize: ({@collection})->

  itemViewOptions: ->