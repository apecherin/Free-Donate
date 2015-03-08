class Fragments.Expenses.MaintenanceOperationsItem extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/expenses/maintenance_operations_item'
  className: 'operation-container'

  events:
    'click .to-edit-mode' : 'toEditMode'
    'click .remove-operation' : 'removeOperation'
    'click .maintenance_operation_cancel' : 'cancelOperation'
    'click .maintenance_operation_save' : 'saveOperation'

  initialize: ({@model, @canEdit, @vehicle, @service_attributes}) ->
    @modeEdit = if @model.isNew() then true else false
    @currentCurrencyRate = Store.get('current_currency_rate')

  onRender: ->
    @$('.maintenance_operation_date').datepicker({format: 'yyyy-mm-dd', separator: '-'}).on "changeDate", (ev) ->
      $(@).blur()

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
        MyApp.vent.trigger('maintenance_operations:update_items')
        MyApp.vent.trigger 'notify:success', I18n.t('destroyed', scope: "notification.#{@model.constructorName}")
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
            MyApp.vent.trigger('maintenance_operations:item_removed')
            MyApp.vent.trigger 'notify:success', I18n.t('destroyed', scope: "notification.#{@model.constructorName}")
    false

  removeItem: ->
    MyApp.vent.trigger("maintenance_operations:item_removed")

  collectData: ->
    name: @$('input.operation-name').val()
    date: @$('input.operation-date').val()
    provider_id: @$('.input.operation-shop').val()
    parts_cost: @$('input.operation-part-cost').val()
    man_hours_cost: @$('input.operation-man-hours-cost').val()
    vehicle_id: @vehicle.id

  serializeData: ->
    maintenanceOperation: @model
    modeEdit: @modeEdit
    canEdit: @canEdit
    providers: @service_attributes.get('providers')
    currentCurrencyRate: @currentCurrencyRate