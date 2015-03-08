class Fragments.Vehicles.PurchaseItem extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/purchase'
  className: 'purchase-item'
  tagName: 'tr'
  events:
    'click .show-part'   : 'showPart'
    'click .show-vendor' : 'showVendor'

  initialize: ({@parts, @vendors})->

  showPart: ->
    view = new Pages.PartPurchases.Show model: @model, vehicle: @model.get('vehicle'), parts: @parts, vendors: @vendors
    MyApp.content.currentView.content.currentView.expenses.show(view)
    false

  showVendor: ->
    vendorName = @model.get('vendor').get('name')
    alert "Show '#{vendorName}' vendor page!"
    false

  serializeData: ->
    purchase: @model
    part:     @model.get('part')
    vendor:   @model.get('vendor')
