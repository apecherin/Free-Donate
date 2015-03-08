#= require ./part_purchase_status_change

class Pages.Vehicles.Modifications.PartPurchaseStatusChanges extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/modifications/part_purchase_status_changes'
  itemView: Pages.Vehicles.Modifications.PartPurchaseStatusChange
  className: 'inline-block'

  events:
    'click .add-status-change' : 'addStatusChange'

  itemViewOptions: ->
    statuses: @partPurchase.availableStatuses()

  appendHtml: (collectionView, itemView)->
    collectionView.$('.status-changes').append itemView.el

  addStatusChange: ->
    @collection.add new Models.PartPurchaseStatusChange part_purchase: @partPurchase
    false

  initialize: ({@partPurchase})->

  serializeData: ->
    showControls: Models.Ability.canManagePartPurchase(@partPurchase)