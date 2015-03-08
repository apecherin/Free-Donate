class Fragments.Vehicles.Purchases extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/purchases'
  events:
    'click a.add-purchase' : 'addPurchase'

  initialize: ({@vehicle, @parts, @vendors})->

  onRender: ->
    purchaseItemsView = new Fragments.Vehicles.PurchaseItems collection: @vehicle.get('part_purchases'), parts: @parts, vendors: @vendors
    purchaseItemsView.render()
    @$('table').append purchaseItemsView.el

  addPurchase: ->
    partPurchase = new Models.PartPurchase
    partPurchase.set vehicle: @vehicle
    partPurchase.collection = @vehicle.get 'part_purchases'

    view = new Pages.PartPurchases.New model: partPurchase, vehicle: @vehicle, parts: @parts, vendors: @vendors
    MyApp.content.currentView.content.currentView.expenses.show view

    false

  serializeData: ->
    brand: @vehicle.get 'brand'
    canManage: Models.Ability.canManageVehicle @vehicle