# FIXME: When we focus a text field an hit Enter, the modal hides.
class Modals.Vendors.New extends Backbone.Marionette.ItemView
  template: 'modals/vendors/new'

  events:
    'submit form' : 'createVendor'

    'change #vendor-name'    : 'changeName'
    'change #vendor-website' : 'changeWebsite'
    'change #vendor-street'  : 'changeStreet'
    'change #vendor-zipcode' : 'changeZipcode'
    'change #vendor-city'    : 'changeCity'
    'change #vendor-country' : 'changeCountry'


  initialize: (attributes)->
    @countries = []
    @vendor    = new Models.Vendor

    $.getJSON '/countries.json', (countries)=>
      @countries = countries
      @render()


  changeName: (event)->
    @vendor.set(name: event.target.value)


  changeWebsite: (event)->
    @vendor.set(website: event.target.value)


  changeStreet: (event)->
    @vendor.set(street: event.target.value)


  changeZipcode: (event)->
    @vendor.set(zipcode: event.target.value)


  changeCity: (event)->
    @vendor.set(city: event.target.value)


  changeCountry: (event)->
    code    = event.target.value
    text    = $(event.target).find('option:selected').text().trim()
    country = { code: code, text: text }

    @vendor.set(country: country)


  createVendor: (event)->
    name    = @vendor.get('name') || ''
    country = @vendor.get('country')

    if 0 < name.length && country
      @trigger('vendor:created', @vendor)
      @vendor.save()
      @close()

    false


  serializeData: ->
    vendor:    @vendor
    countries: @countries


  onRender: ->
    callback = => @$('select').chosen(no_results_text: ' ')
    setTimeout(callback, 0)
