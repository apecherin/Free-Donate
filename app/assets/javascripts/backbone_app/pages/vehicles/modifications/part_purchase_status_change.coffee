class Pages.Vehicles.Modifications.PartPurchaseStatusChange extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/part_purchase_status_change'

  events:
    'click .delete-status-change' : 'deleteStatusChange'
    'click .save:not(.disabled)'  : 'saveStatusChange'
    'click .cancel'               : 'cancelEditing'
    'change .input'               : 'enableSaveButton'

  isEditMode:         Pages.Mixins.isEditMode
  deleteStatusChange: Pages.Mixins.destroyModel
  cancelEditing:      Pages.Mixins.cancelEditing
  enableSaveButton:   Pages.Mixins.enableSaveButton
  saveStatusChange:   Pages.Mixins.saveModel

  initialize: ({@statuses})->

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)
    @$('#part_purchase_status_change_new_date').datepicker({format: 'yyyy-mm-dd', separator: '-'}).on "changeDate", (ev) ->
      $(@).blur()
#      callbacks = =>
#        $('.save:not(.disabled)').trigger('click')
#      setTimeout callbacks, 200

  saveModel: ->
    callbacks = =>
      @saveStatusChange
    setTimeout callbacks, 0

  collectData: ->
    baseId = "##{HAML.globals()['domId'](@model)}"

    status: @$("#{baseId}_status").val()
    date: @$("#{baseId}_date").val()

  serializeData: ->
    statusChange: @model
    isEditMode: @isEditMode()
    showControls: Models.Ability.canManagePartPurchaseStatusChange(@model)
    statuses: @statuses