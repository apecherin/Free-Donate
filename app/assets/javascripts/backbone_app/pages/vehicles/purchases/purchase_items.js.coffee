class Fragments.Vehicles.PurchaseItems extends Backbone.Marionette.CollectionView
  itemView:  Fragments.Vehicles.PurchaseItem
  tagName:   'tbody'
  className: 'purchase-items'

  initialize: ({@parts, @vendors})->

  itemViewOptions: ->
    parts:   @parts
    vendors: @vendors