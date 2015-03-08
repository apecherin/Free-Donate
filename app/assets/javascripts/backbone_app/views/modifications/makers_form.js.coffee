class Fragments.Vehicles.Modifications.MakersForm extends Backbone.Marionette.ItemView
  template: 'fragments/modifications/makers_form'

  events:
    'click #save-new-vendor' : 'saveVendor'
    'click #cancel-new-vendor' : 'cancelNewVendor'

  initialize: ({@vendor, @tab, @countries_list, @vendorName})->


  onRender: ->
    _.defer => @$('.company-country-code').chosen()

  saveVendor: ->
    @model = new Models.Vendor
    @model.set @collectData()
    @model.save null,
      success: =>
        MyApp.vent.trigger 'vendor:created', @tab, @model.id
        MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: "notification.vendor")
      error: =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: "notification.vendor")

  cancelNewVendor: (event) ->
    MyApp.vent.trigger('vendor:canceled', @tab)
    false

  collectData: ->
    name:    @$('input.company-name').val()
    street:  @$('input.company-street').val()
    zipcode: @$('input.company-zipcode').val()
    city:    @$('input.company-city').val()
    country_code: @$('select.company-country-code').val()
    website: @$('input.company-website').val()
    type: @tab.capitalize()

  serializeData: ->
    vendor: new Models.Vendor(name: @vendorName)
    countries: @countries_list