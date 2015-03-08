class Pages.Vehicles.Modifications.ModificationItem extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/modification_item'

  regions:
    'socialActions'  : '#social-actions'

  events:
    'change select.state'        : 'updateModificationState'
    'click .save:not(.disabled)' : 'saveModification'
    'click .edit'                : 'switchToEditMode'
    'click .remove'              : 'deleteModification'
    'click .cancel'              : 'cancelEditing'
    'change .input'              : 'enableSaveButton'

  cancelEditing: Pages.Mixins.cancelEditing
  deleteModification: Pages.Mixins.destroyModel
  enableSaveButton: Pages.Mixins.enableSaveButton
  saveModification: Pages.Mixins.saveModel
  isEditMode: Pages.Mixins.isEditMode
  switchToEditMode: Pages.Mixins.switchToEditMode

  initialize: ({})->
    @currentUser = Store.get('currentUser')
    @bindTo MyApp.vent, 'part_purchase_status_change:created', @changeStatus
    @bindTo MyApp.vent, 'part_purchase_status_change:removed', @changeStatus

  onRender: ->
    @socialActions.show new Fragments.Vehicles.Modifications.SocialActions
      modification: @model
      currentUser: @currentUser
      modelUser: @model.get('user')

  changeStatus: ->
    @render()

  updateModificationState: ->
    if @$('select.state').val() is 'public'
      @model.publish
        success: =>
          MyApp.vent.trigger 'notify:success', I18n.t('published', scope: "notification.#{@model.constructorName}")
        error: =>
          MyApp.vent.trigger 'notify:error', I18n.t('error', scope: "notification.#{@model.constructorName}")
    else
      @model.hide
        success: =>
          MyApp.vent.trigger 'notify:success', I18n.t('hided', scope: "notification.#{@model.constructorName}")
        error: =>
          MyApp.vent.trigger 'notify:error', I18n.t('error', scope: "notification.#{@model.constructorName}")

  serializeData: ->
    isEditMode:   @isEditMode()
    modification: @model
    states:       Models.Modification.states()
    showControls: Models.Ability.canManageChangeSet(@model)
