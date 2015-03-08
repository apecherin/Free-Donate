#= require ./modification_purchase

class Pages.Vehicles.Modifications.ModificationPart extends Pages.Vehicles.Modifications.ModificationPurchase
  template: 'pages/vehicles/modifications/modification_part'

  events:
    'click .save:not(.disabled)'  : 'savePurchase'
    'click .edit'                 : 'switchToEditMode'
    'click .remove'               : 'deletePurchase'
    'click .cancel'               : 'cancelEditing'
    'change .input'               : 'enableSaveButton'
    'change select'               : 'enableSaveButton'
    'click .upload-pictures'      : 'clickFileInput'
    'change .part-purchase-state' : 'updatePurchaseState'
    'click .save-maker'           : 'saveMaker'

  regions:
    categoriesContainer:    '.categories-container'
    partPurchasesContainer: '.part-purchases-container'
    picturesContainer:      '.purchase-pictures-container'
    statusChangesContainer: '.status-changes-container'
    manufacturersContainer: '.manufacturers-container'
    suppliersContainer:     '.suppliers-container'
    vendorsContainer:       '.vendors-container'

  initialize: ({@purchaseAttributes, @currentPurchasePictureId, @cps_tab, @itemPosition, @user})->
    @currentCurrencyRate = if @model.isNew() then Store.get('current_currency_rate') else @model.get('currency_rate')[Store.get('currentCurrency').toLowerCase()]
    @currentUser = Store.get('currentUser')
    @bindTo MyApp.vent, 'part_purchase_status_change:created', @changeStatus
    @bindTo MyApp.vent, 'part_purchase_status_change:removed', @changeStatus
    @bindTo MyApp.vent, 'part_purchase_picture:removed', @changeStatus

    @currentPurchasePictureId = if @currentPurchasePictureId? then @currentPurchasePictureId else null
    @parts = @purchaseAttributes.get('parts')
    @manufacturers = @purchaseAttributes.get('manufacturers')
    @suppliers = @purchaseAttributes.get('suppliers')
    @vendors = @purchaseAttributes.get('vendors')
    @editMode = false

  changeStatus: ->
    @render()

  onRender: ->
    super()
    @updated_collection = @model.get('pictures')
    @updated_collection = new Collections.PartPurchasePictures @updated_collection.where({type: 'picture'})
    size_of_collection = @updated_collection.size()
    if size_of_collection < 5
      n = 0
      loop
        @updated_collection.push new Models.PartPurchasePicture(id: 99999 - n, type: 'fake', position: 5-n)
        n++
        break if (n >= 5-size_of_collection)
    @without_fakes = @updated_collection.where({type: 'picture'})

    @picturesContainer.show new Pages.Vehicles.Modifications.PurchasePictures
      collection: @updated_collection
      pictures: new Collections.PartPurchasePictures @without_fakes
      modification: @model.get('modification')
      currentPurchasePictureId: @currentPurchasePictureId
      cps_tab: @cps_tab
    @statusChangesContainer.show new Pages.Vehicles.Modifications.PartPurchaseStatusChanges collection: @model.get('status_changes'), partPurchase: @model
    if @isEditMode()
      user_makers = new Collections.UserMakers
      user_makers.fetch data: {user_id: @user.id}, success: (user_makers) =>
        @manufacturersContainer.show new Fragments.Vehicles.Modifications.VendorsList partPurchase: @model, vendorType: 'manufacturer', vendors: new Collections.UserMakers(user_makers.where(type: 'Manufacturer')), user: @user
        @suppliersContainer.show new Fragments.Vehicles.Modifications.VendorsList partPurchase: @model, vendorType: 'supplier', vendors: new Collections.UserMakers(user_makers.where(type: 'Supplier')), user: @user
        @vendorsContainer.show new Fragments.Vehicles.Modifications.VendorsList partPurchase: @model, vendorType: 'vendor', vendors: new Collections.UserMakers(user_makers.where(type: 'Vendor')), user: @user
        @categoriesContainer.show new Fragments.Vehicles.Modifications.AvailableCategories partPurchase: @model
        @partPurchasesContainer.show new Fragments.Vehicles.Modifications.AvailablePartPurchases partPurchase: @model

    @currentPurchasePictureId = @cps_tab = null

  collectData: ->
    baseId = "##{HAML.globals()['domId'](@model)}"

    quantity_value = @$("#{baseId}_quantity").val()
    quantity = parseInt(quantity_value)
    quantity = quantity_value if isNaN(quantity)

    price_value = @$("#{baseId}_price").val()
    price = parseFloat(price_value)
    price = price_value if isNaN(price)

    part: @$("#{baseId}_part").val()
    category: @$("#{baseId}_category").val()
    description: @$("#{baseId}_description").val().capitalize()
    quantity: quantity
    price: price
    manufacturer: if @$("select[data-type='manufacturer']").val() in [0, -1, '0', '-1'] then '' else new Models.Vendor id: @$("select[data-type='manufacturer']").val()
    supplier: if @$("select[data-type='supplier']").val() in [0, -1, '0', '-1'] then '' else new Models.Vendor id: @$("select[data-type='supplier']").val()
    vendor: if @$("select[data-type='vendor']").val() in [0, -1, '0', '-1'] then '' else new Models.Vendor id: @$("select[data-type='vendor']").val()
    manufacturer_reference: @$("#{baseId}_manufacturer_reference").val()
    supplier_reference: @$("#{baseId}_supplier_reference").val()
    vendor_reference: @$("#{baseId}_vendor_reference").val()
    state: 'unknown'

  updatePurchaseState: (event) ->
    @model.set state: @$(event.currentTarget).val()
    @model.save null,
      success: =>
        MyApp.vent.trigger 'notify:success', I18n.t('upadated_state', scope: "notification.part_purchase")

  saveMaker: (event) ->
    maker_id = @$(event.currentTarget).data('id')
    user_makers = new Collections.UserMakers
    user_makers.fetch data: {user_id: @currentUser.id}, success: (user_makers) =>
      if maker_id in user_makers.map('id')
        MyApp.vent.trigger 'notify:warning', I18n.t('already_have_maker', scope: "notification.part_purchase")
      else
        $.ajax(type: 'POST', url:  "/api/maker_import", data: {maker_id: maker_id})
          .success (data)=>
            MyApp.vent.trigger 'notify:success', I18n.t('maker_imported', scope: "notification.part_purchase")
          .error (data) =>
            MyApp.vent.trigger 'notify:error', I18n.t('already_have_maker', scope: "notification.part_purchase")
    false

  serializeData: ->
    itemPosition: @itemPosition
    partPurchase: @model
    vendor: @model.get('vendor')
    manufacturer: @model.get('manufacturer')
    modification: @model.get('modification')
    supplier: @model.get('supplier')
    statuses: Models.Modification.statuses()
    states: Models.PartPurchase.states()
    isEditMode: @isEditMode()
    showControls: Models.Ability.canManagePartPurchase(@model)
    currentUser: @currentUser
    currentCurrencyRate: @currentCurrencyRate