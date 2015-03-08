class Pages.Vehicles.Modifications.ModificationProperty extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/modification_property'
  className: 'row-container'

  events:
    'change .name'               : 'changeCurrentProperty'
    'change .value'              : 'changeValue'
    'keyup  .value'              : 'enableSaveButton'
    'click .save:not(.disabled)' : 'saveProperty'
    'click .cancel'              : 'cancelEditing'
    'click .edit'                : 'switchToEditMode'
    'click .remove'              : 'deleteProperty'

  cancelEditing:    Pages.Mixins.cancelEditing
  deleteProperty:   Pages.Mixins.destroyModel
  enableSaveButton: Pages.Mixins.enableSaveButton
  isEditMode:       Pages.Mixins.isEditMode
  saveProperty:     Pages.Mixins.saveModel
  switchToEditMode: Pages.Mixins.switchToEditMode

  initialize: ({@propertyDefinitions, @versionProperties})->
    @propertyNames = Object.keys(@propertyDefinitions)
    if @model.isNew()
      @versionProperty = @versionProperties.findByName @propertyNames.first()
      @selectedPropertyName = @versionProperty.get('name')
      @model.set value: @versionProperty.get('value'), name: @selectedPropertyName
      @model.isCustomValid()
    else
      @selectedPropertyName = @model.get('name')
      @versionProperty = @versionProperties.findByName @selectedPropertyName

    @currentValue = @model.get('value')

  changeCurrentProperty: (e)->
    @selectedPropertyName = @$(e.target).val()
    @versionProperty = @versionProperties.findByName @selectedPropertyName
    @currentValue = @versionProperty.get('value')
    @updateDifference()
    @updateStockValue()
    @updateValue()
    @updateUnits I18n.t(@propertyDefinitions[@selectedPropertyName], scope: 'units_new.unit_symbols')
    false

  updateUnits: (unit)->
    @$('.with-unit').siblings('.add-on').html unit

  changeValue: (e)->
    @currentValue = parseFloat(@$(e.target).val())
    @updateDifference()
    false

  updateValue: ->
    @$('.value').val @currentValue

  updateDifference: ->
    @$('.difference').val @differenceValue()

  updateStockValue: ->
    @$('.stock-value').val @versionProperty.get('value')

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)
    setTimeout (=> @$('.chosen').chosen()), 0

  collectData: ->
    name:  @selectedPropertyName
    value: if @model.stringProperty(@selectedPropertyName) then @$('.value').val() else parseFloat(@$('.value').val())


  differenceValue: ->
    if !isNaN(@currentValue)
      (@currentValue - @versionProperty.get('value')).toFixed(2)
    else
      'N/A'

  serializeData: ->
    property:             @model
    propertyNames:        @propertyNames
    selectedPropertyName: @selectedPropertyName
    stockValue:           if @versionProperty? then @versionProperty.get('value') else 0
    difference:           @differenceValue()
    currentValue:         @currentValue
    propertyUnit:         I18n.t(@propertyDefinitions[@selectedPropertyName], scope: 'units_new.unit_symbols')
    isEditMode:           @isEditMode()
    showControls:         Models.Ability.canManageModificationProperty @model