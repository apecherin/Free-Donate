class Pages.PartPurchases.Show extends Backbone.Marionette.ItemView
  template: 'pages/part_purchases/show'

  events:
    'click .show-listing' : 'showListing'

  initialize: ({@vehicle, @parts, @vendors})->

  # These information MUST be present.
  serializeData: ->
    purchase: @model
    vendor:   @model.get('vendor')
    part:     @model.get('part')
    brand:    @vehicle.get('brand')

  showListing: ->
    view = new Fragments.Vehicles.Purchases vehicle: @vehicle, parts: @parts, vendors: @vendors
    MyApp.content.currentView.content.currentView.expenses.show view
    false
