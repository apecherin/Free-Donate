class Fragments.Vehicles.Modifications.VendorsList extends Backbone.Marionette.Layout
  template: 'fragments/modifications/vendors_list'

  regions:
    searchfield: '.searchfield'

  initialize: ({@partPurchase, @vendorType, @vendors, @user}) ->
#    @bindTo MyApp.vent, 'vendor:created', @addNewVendorByID
#    @bindTo MyApp.vent, 'vendor:canceled', @clearPartInput

  onRender: ->
    @searchfield.show new Fragments.Vehicles.Modifications.VendorsSearchfield
      vendorType: @vendorType
      vendors: @vendors
      user: @user
      input_id: @partPurchase.get(@vendorType)?.get('id')

  clearPartInput: (tab) ->
    input = @$("input[data-type='#{tab}']")
    input.val('')
    input.focus()
    @$('button.add-new-vendor').hide()

  addNewVendorByID: (tab, id)->
    input = @$("input[data-type='#{tab}']")
    purchase_attrs = new Models.PartPurchaseAttributes
    purchase_attrs.fetch wait: true, success: (attrs) =>
      new_vendor = attrs.get("#{tab}s").find (vendor) -> vendor.get('id') is id.toNumber()
      input.attr('data-id', new_vendor.get('id'))
      input.val(new_vendor.get('name'))
      @$('button.add-new-vendor').hide()
      $('a.save').removeClass('disabled')

  serializeData: ->
    partPurchase: @partPurchase
    vendorType:   @vendorType
