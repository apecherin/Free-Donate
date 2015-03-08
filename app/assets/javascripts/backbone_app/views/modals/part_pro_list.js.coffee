class Modals.PartProList extends Backbone.Marionette.Layout
  template: 'modals/part_pro_list'

  regions:
    vendorForm : '#vendor-form'

  initialize: ({@vendorType, @newVendorName, @user}) ->
    @tab =
      if @vendorType is 'manufacturer'
        'oem'
      else if @vendorType is 'supplier'
        'suppliers'
      else
        'vendors'
    @bindTo MyApp.vent, 'vendor:created', @closeModal
    @bindTo MyApp.vent, 'vendor:canceled', @closeModal

  onRender: ->
    @vendorForm.show new Pages.Users.ProList.Dashboard
      user: @user
      activeTab: @tab
      isPopup: true

  closeModal: ->
    @close()

  serializeData: ->
    newVendorName: @newVendorName
    vendorType: @vendorType