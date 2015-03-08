class Fragments.Expenses.TrackOperationsItem extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/expenses/track_operations_item'
  className: 'operation-container'

  events:
    'click .to-edit-mode' : 'toEditMode'
    'click .remove-operation' : 'removeOperation'
    'click .track_operation_cancel' : 'cancelOperation'
    'click .track_operation_save' : 'saveOperation'
    'change .operation-energy' : 'setQualityValues'
#    'change .operation-quality' : 'setQuantityValues'

  initialize: ({@model, @canEdit, @vehicle}) ->
    @modeEdit = if @model.isNew() then true else false
    @energyTypes = {
      'petrol' : {
        'qualityTypes' : [''].concat(_.range(85, 111).reverse()),
        'quantityUnits' : ['', 'ltr', 'gal']
      },
      'ethanol' : {
        'qualityTypes' : ['', 'e10', 'e85'],
        'quantityUnits' : ['', 'ltr', 'gal']
      },
      'methanol' : {
        'qualityTypes' : ['', '50%', '100%'],
        'quantityUnits' : ['', 'ltr', 'gal']
      },
      'gas' : {
        'qualityTypes' : ['', 'lpg', 'natural gas', 'butane', 'propane', 'hydrogen'],
        'quantityUnits' : ['', 'ltr', 'gal']
      },
      'diesel' : {
        'qualityTypes' : ['', 'summer', 'winter'],
        'quantityUnits' : ['ltr', 'gal']
      },
      'electricity' : {
        'qualityTypes' : ['', 'home', 'road', 'supercharger'],
        'quantityUnits' : ['', 'kw']
      }
    }
    @currentCurrencyRate = Store.get('current_currency_rate')

  onRender: ->
    @$('.track_operation_date').datepicker({format: 'yyyy-mm-dd', separator: '-'}).on "changeDate", (ev) ->
      $(@).blur()
#    unless @modeEdit
#      @setOdometerValue('.operation-odometer', @model.get('odometer'))

  setQualityValues: (event) ->
    if @model.get('type') is 'EnergyTrack' && @modeEdit
      energy = event.currentTarget.value
      unless energy is ''
        @$('.operation-quality').find('option').remove()
        quality_types = @energyTypes[energy]['qualityTypes']
        quality_types.each (type)=>
          selected = @model.get('quality') == type
          @$('.operation-quality').append('<option value="' + type + '" selected="' + selected + '">' + type + '</option>')
        @setQuantityValues()

  setQuantityValues: (event, force_quality='') ->
    quality = event?.currentTarget.value
    energy = @$('.operation-energy option:selected').val()
    if quality isnt '' && energy isnt ''
      @$('.operation-quantity-unit').text('')
      $.ajax(type: 'POST', url:  "/api/vehicle_track/energy_unit", data: {energy: energy})
        .success (data)=>
          @$('.operation-quantity-unit').text(data.quantity_unit)

  setOdometerValue: (odometer_class, value) ->
    setTimeout (->
      el = $(odometer_class)
      od = new Odometer(
        el: el[0]
        value: 0
      )
      od.update value

      setTimeout (->
        odometer_zero_digit = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"><span class="odometer-ribbon"><span class="odometer-ribbon-inner"><span class="odometer-value">0</span></span></span></span></span>'
        inside = $(odometer_class + ' .odometer-inside')
        current_digit_count = inside.find('.odometer-digit').length
        diff = window.odometerOptions.min_count - current_digit_count

        n = 0
        while n < diff
          n++
          inside.prepend(odometer_zero_digit)
      ), 2200
    ), 100

  toEditMode: () ->
    @modeEdit = true
    @render()
    false

  toViewMode: () ->
    @modeEdit = false
    @render()
    false

  saveOperation: () ->
    @model.set @collectData()
    @model.save null,
      success: (model)=>
        MyApp.vent.trigger('track_operations:update_items')
        MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: "notification.#{@model.constructorName}")
        @toViewMode()
      error: =>
        @toViewMode()

    false

  cancelOperation: () ->
    if @model.isNew()
      @removeItem()
    else
      @toViewMode()
    false

  removeOperation: ->
    bootbox.confirm I18n.t('delete', scope: "bootbox.#{@model.constructorName}"), (submit) =>
      if submit
        @model.destroy
          wait: true
          success: =>
#            $('.mods-actions').removeClass 'disable-mods-actions'
            MyApp.vent.trigger('track_operations:item_removed')
            MyApp.vent.trigger 'notify:success', I18n.t('destroyed', scope: "notification.#{@model.constructorName}")
    false

  removeItem: ->
    MyApp.vent.trigger("track_operations:item_removed")

  collectData: ->
    name: @$('input.operation-name').val()
    date: @$('input.operation-date').val()
    cost: @$('input.operation-cost').val()
    quantity_value: @$('input.operation-quantity-value').val() || ''
    energy: @$('select.operation-energy').val() || ''
    quality: @$('select.operation-quality').val() || ''
    odometer: @$('input.operation-odometer').val() || ''
    vehicle_id: @vehicle.id

  serializeData: ->
    trackOperation: @model
    modeEdit: @modeEdit
    canEdit: @canEdit
    energyTypes: @energyTypes
    currentCurrencyRate: @currentCurrencyRate