class Pages.Vehicles.Modifications.ChangeSetGeneralInfo extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/change_set_general_info'
  className: 'change-set-controls'

  events:
    'click .delete-change-set'        : 'deleteChangeSet'
    'change input.current-change-set' : 'setCurrent'
    'click .edit'                     : 'switchToEditMode'
    'click .cancel'              : 'cancelEditing'
    'click .save:not(.disabled)' : 'saveModification'
    'keyup .input'               : 'enableSaveButton'

  deleteChangeSet:    Pages.Mixins.destroyModel
  enableSaveButton:   Pages.Mixins.enableSaveButton
  isEditMode:         Pages.Mixins.isEditMode
  saveModification:   Pages.Mixins.saveModel
  switchToEditMode:   Pages.Mixins.switchToEditMode
  cancelEditing:      Pages.Mixins.cancelEditing

  initialize: ->
    @bindTo MyApp.vent, 'current_change_set:updated', @render

  onRender: ->
    if @isEditMode()
      Pages.Mixins.focusInput @$("##{HAML.globals()['domId'](@model)}_name")

  setCurrent: (e)->
    vehicle = @model.get('vehicle')
    if @$(e.target).is(':checked')
      vehicle.set 'current_change_set_id', @model.id, silent: true
      message = 'Setup is set as current'
    else
      vehicle.set 'current_change_set_id', null, silent: true
      message = 'Setup is unset as current'

    # TODO: in Backbone 0.9.2 silent: true has weird behaviour. Update to 0.9.10 and get rid of this.
    vehicle.save {},
      wait: true
      silent: true
      success: =>
        MyApp.vent.trigger 'current_change_set:updated'
        MyApp.vent.trigger 'notify:success', message

    false

  collectData: ->
    baseId = "##{HAML.globals()['domId'](@model)}"
    name:     @$("#{baseId}_name").val()

  serializeData: ->
    changeSet:    @model
    showControls: Models.Ability.canManageChangeSet @model
    isEditMode:   @isEditMode()