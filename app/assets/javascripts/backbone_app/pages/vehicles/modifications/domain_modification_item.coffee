#= require /pages/properties/property_bars

class Pages.Vehicles.Modifications.DomainModificationItem extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/domain_modification_item'

  regions:
    'propertyBars'   : '.modification-properties-container'
    'coverContainer' : '.modification-preview-image'
    'socialActions'  : '#social-actions'

  events:
    'click .cancel'              : 'cancelEditing'
    'click .save:not(.disabled)' : 'saveModification'
    'click .edit'                : 'switchToEditMode'
    'click .remove'              : 'deleteModification'
    'keyup .input'               : 'enableSaveButton'
    'change select.input'        : 'enableSaveButton'
    'keyup input.input'          : 'checkForSubmit'
    'click .modification-name'   : 'renderSocialActionsAfterView'


  cancelEditing:      Pages.Mixins.cancelEditing
  deleteModification: Pages.Mixins.destroyModel
  enableSaveButton:   Pages.Mixins.enableSaveButton
  isEditMode:         Pages.Mixins.isEditMode
  saveModification:   Pages.Mixins.saveModel
  switchToEditMode:   Pages.Mixins.switchToEditMode

  initialize: ({@indexNumber, @versionProperties})->
    @currentUser = Store.get('currentUser')

  onRender: ->
    @$el.addClass HAML.globals()['domId'](@model)

    maxPropertiesToShow = 3
    if !@editMode && @model.get('properties').length
      if @model.get('properties').length > maxPropertiesToShow
        properties = @model.get('properties').shuffle().slice(0, maxPropertiesToShow)
      else
        properties = @model.get('properties').models

      @propertyBars.show new Pages.Properties.PropertyBars collection: new Backbone.Collection(properties), versionProperties: @versionProperties

    if @isEditMode()
      Pages.Mixins.focusInput @$("##{HAML.globals()['domId'](@model)}_name")
    else
      coverPicture = @model.coverPicture()
      if typeof coverPicture isnt 'undefined'
        @coverContainer.show new Pages.Vehicles.Modifications.PurchasePicture model: coverPicture, showControls: false

    if @model.get('user')?
      @socialActions.show new Fragments.Vehicles.Modifications.SocialActions
        modification: @model
        currentUser: @currentUser
        modelUser: @model.get('user')

  checkForSubmit: (event)->
    if event.keyCode is 13
      @$('.save').click()

  renderSocialActionsAfterView: ->
    modificationView = new Models.ModificationView
      modification_id: @model.get('id')
    modificationView.save null, success: =>
      @model.fetch success: =>
        @render()

  collectData: ->
    baseId = "##{HAML.globals()['domId'](@model)}"
    name:     (@$("#{baseId}_name").val()).titlelize()

  serializeData: ->
    modification: @model
    indexNumber:  @indexNumber + 1
    isEditMode:   @isEditMode()
    showControls: Models.Ability.canManageModification(@model)
    currentUser: @currentUser