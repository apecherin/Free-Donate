Pages.PartPurchases.New = Backbone.Marionette.ItemView.extend
  template: 'pages/part_purchases/new'

  events:
    'click .show-listing' : 'cancel'
    'click a.add-vendor'  : 'addVendor'
    'click a.add-part'    : 'addPart'
    'submit form'         : 'createPurchase'

  initialize: ({@vehicle, @parts, @vendors})->

  onRender: ->
    callback = =>
      @$('select').chosen(no_results_text: ' ')

    setTimeout(callback, 0)

  serializeData: ->
    vehicle:  @vehicle
    vendors:  @vendors
    parts:    @parts
    purchase: @model

  cancel: ->
    @model.destroy()
    @showListing()

  showListing: ->
    view = new Fragments.Vehicles.Purchases vehicle: @vehicle, parts: @parts, vendors: @vendors
    MyApp.content.currentView.content.currentView.expenses.show view
    false

  addVendor: ->
    modal = new Modals.Vendors.New(purchase: @model)
    @bindTo modal, 'vendor:created', (vendor)->
      @model.set(vendor: vendor)
      @vendors.add(vendor)

    MyApp.modal.show(modal)
    false

  addPart: ->
    part  = new Models.Part(brand: @vehicle.get('brand'))
    modal = new Modals.Parts.New(vehicle: @vehicle, part: part)
    @bindTo modal, 'part:created', (part)->
      @model.set(part: part)
      @parts.add(part)

    MyApp.modal.show(modal)
    false

  collectData: ->
    bought_at: @$('input[name=date]').val()
    quantity:  @$('#quantity').val()
    price:     @$('#price').val()
    special:   @$("#special").prop('checked')
    part_id:   @$('#part').val()
    vendor_id: @$('#vendor').val()

  createPurchase: (event)->
    @model.set @collectData()
    @model.save null,
      success: (model)=>
        @vehicle.get('part_purchases').add model
        @showListing()
      error: =>
        @cancel()

    false