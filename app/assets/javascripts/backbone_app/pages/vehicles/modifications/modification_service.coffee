#= require ./modification_purchase

class Pages.Vehicles.Modifications.ModificationService extends Pages.Vehicles.Modifications.ModificationPurchase
  template: 'pages/vehicles/modifications/modification_service'

  events:
    'click .save:not(.disabled)' : 'savePurchase'
    'click .edit'                : 'switchToEditMode'
    'click .remove'              : 'deletePurchase'
    'click .cancel'              : 'cancelEditing'
    'change .input'              : 'enableSaveButton'
    'click .upload-pictures'     : 'clickFileInput'

  initialize: ({@purchaseAttributes, @currentPurchasePictureId, @cps_tab})->
    @currentCurrencyRate = if @model.isNew() then Store.get('current_currency_rate') else @model.get('currency_rate')[Store.get('currentCurrency').toLowerCase()]
    @bindTo MyApp.vent, 'part_purchase_picture:removed', @changeStatus

    @currentPurchasePictureId = if @currentPurchasePictureId? then @currentPurchasePictureId else null
    @providers = @purchaseAttributes.get('providers')
    @editMode = false

  changeStatus: ->
    @render()

  onRender: ->
    super()
    @updated_collection = @model.get('pictures')
    @updated_collection = new Collections.ServicePictures @updated_collection.where({type: 'picture'})
    size_of_collection = @updated_collection.size()
    if size_of_collection < 5
      n = 0
      loop
        @updated_collection.push new Models.ServicePicture(id: 99999 - n, type: 'fake', position: 5-n)
        n++
        break if (n >= 5-size_of_collection)
    @without_fakes = @updated_collection.where({type: 'picture'})

    @picturesContainer.show new Pages.Vehicles.Modifications.PurchasePictures
      collection: @updated_collection
      pictures: new Collections.ServicePictures @without_fakes
      modification: @model.get('modification')
      currentPurchasePictureId: @currentPurchasePictureId
      cps_tab: @cps_tab

    @$('input.bought_at_calendar').datepicker({format: 'yyyy-mm-dd', separator: '-'}).on "changeDate", (ev) ->
      $(@).blur()

    @currentPurchasePictureId = null

  collectData: ->
    baseId = "##{HAML.globals()['domId'](@model)}"

    hourly_rate_value = @$("#{baseId}_hourly_rate").val()
    hourly_rate = parseFloat(hourly_rate_value)
    hourly_rate = hourly_rate_value if isNaN(hourly_rate)

    duration_value = @$("#{baseId}_duration").val()
    duration = parseFloat(duration_value )
    duration = duration_value  if isNaN(duration)

    bought_at: @$("#{baseId}_bought_at").val()
    description: @$("#{baseId}_description").val()
    provider: @providers.get @$("#{baseId}_provider_id").val()
    hourly_rate: hourly_rate
    service_type: @$("#{baseId}_service_type").val()
    duration: duration
    quality: @$("#{baseId}_quality").val()

  serializeData: ->
    service: @model
    serviceTypes: Models.Service.serviceTypes()
    qualityTypes: Models.Service.qualityTypes()
    provider: @model.get('provider')
    providers: @providers.models
    isEditMode: @isEditMode()
    showControls: Models.Ability.canManageService(@model)
    currentCurrencyRate: @currentCurrencyRate