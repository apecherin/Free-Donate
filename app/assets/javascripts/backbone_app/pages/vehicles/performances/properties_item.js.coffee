class Fragments.Vehicles.Performances.PropertiesItem extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/performances/properties_item'
  tagName: 'tr'

  events:
    'change .property-value'                    : 'changeValue'
    'change .dependent-property-value'          : 'changeDependentValue'
    'click .property-validation-action-accept'  : 'acceptPendingValue'
    'click .property-validation-action-reject'  : 'rejectPendingValue'

  initialize: ({@showControls, @showCurrent, @dependant_collection, @props_dependencies, @current_change_set, @vehicle, @modifications}) ->
    @mods_values = []
    if @modifications?
      @modded = @modifications.reduce((memo, modification)=>
        property = modification.get('properties').find (property)=> property.get('name') is @model.get('name')
        if property? and property.get('value')?
          @mods_values.push(property.get('value'))
          memo + property.get('value')
        else
          memo
      , 0)
      @correction_factor = @model.get('correction_factor')
      @modded = @calcModsValue(@mods_values, @model)
    @currentProperty = @current_change_set.get('properties').find (prop)=> prop.get('name') is @model.get('name')
    @currentUser = Store.get('currentUser')

    if @dependant_collection? and @props_dependencies?
      dependant_property_name = @props_dependencies[@model.get('name')]
      @stock_dependant_property = @dependant_collection.find (prop)=> prop.get('name') is dependant_property_name
      if @showCurrent
        @current_dependant_property = @current_change_set.get('properties').find (prop)=> prop.get('name') is dependant_property_name

    @vehicleUserId = @vehicle.get('user')?.id
    @ownsVehicle = @vehicleUserId and @currentUser? and @vehicleUserId is @currentUser.id
    if !@isEditing() and @model.id
      @fetchPendingCorrections()

  calcModsValue: (mods_values, stock) ->
    return false if mods_values.length is 0 || stock is 'undefined' || stock.get('name') in ['energy', 'cylinders']
    sum_mods_values = mods_values.reduce (a, b) -> a + b
    value = sum_mods_values - ((mods_values.length - 1) * stock.get('value'))
    @correction_factor = if @correction_factor in ['', null, undefined] then 0 else @correction_factor
    value + @correction_factor.toNumber()

  fetchPendingCorrections: ->
    @pendingCorrections = new Collections.Corrections()
    @pendingCorrections.version_property_id = @model.id
    promise = @pendingCorrections.fetch()
    @waitingForCorrections = true
    promise.then =>
      @waitingForCorrections = false
      @render()

  render: ->
    return if @waitingForCorrections
    Backbone.Marionette.ItemView.prototype.render.apply(this, arguments)

  onRender: ->
    @$el.addClass @model.get('name')
    _.defer =>
      if @model.get('value')? and (@model.get('accepted') or @ownsVehicle)
        @$el.addClass('property-showing')
        @setHoverBindings()

  onClose: ->
    @$el.off('mouseenter')
    @$el.off('mouseleave')

  setHoverBindings: ->
    @$el.on 'mouseenter', (e) =>
      $tr = $(e.currentTarget)
      $tr.find('.property-source').show()
    @$el.on 'mouseleave', (e) =>
      $tr = $(e.currentTarget)
      $tr.find('.property-source').hide()

  isEditing: ->
    @showControls

  acceptPendingValue: (e) ->
    if @canShowCorrectionValidationHover()
      correction = @pendingCorrections.at(0)
      correction.set accept: true
      promise = correction.save({})
      promise.then =>
        @model.set('value', correction.get('value'))
        @model.set('user', correction.get('user'))
        @pendingCorrections.remove(correction)
        @render()
    else if @canShowValueValidationHover()
      promise = @model.save({ accepted: true, vehicle_id: @vehicle.id, validating: true })
      promise.then =>
        @render()
    false

  rejectPendingValue: (e) ->
    if @canShowCorrectionValidationHover()
      correction = @pendingCorrections.at(0)
      promise = correction.save({reject: true})
      promise.then =>
        @pendingCorrections.remove(correction)
        @render()
    else if @canShowValueValidationHover
      promise = @model.save({ accepted: false, vehicle_id: @vehicle.id, validating: true })
      promise.then =>
        @model.set('value', null)
        @model.set('user', null)
        @render()
    false

  changeValue: (e) ->
    data = @collectData($(e.target))
    if @ownsVehicle or !@model.get('value')?
      @model.save(data)
    else
      data.version_property_id = @model.id
      correction = new Models.Correction(data)
      correction.save(data)
    false

  collectData: (source)->
    if source.attr('name') is 'correction_factor'
      { correction_factor: source.val().replace(',', '.'), vehicle_id: @vehicle.id }
    else
      { value: source.val().replace(',', '.'), vehicle_id: @vehicle.id }

  changeDependentValue: (e)->
    @dependant_property.save @collectData($(e.target))
    false

  serializeProperty: (property, prefix)->
    res = {}
    if property?
      res["#{prefix}Name"]  = property.get('name')
      res["#{prefix}Value"] = property.get('value')
      res["#{prefix}Unit"]  = I18n.t(Seeds.propertyDefinitions[property.get('name')], scope: 'units_new.unit_symbols') || ''
    res

  isCurrentValueSuggested: ->
    @vehicleUserId isnt @model.get('user').id

  canShowValueSuggestedHover: ->
    !@isEditing() and @isCurrentValueSuggested() and @model.get('value')? and @model.get('accepted')

  canShowValueValidationHover: ->
    !@isEditing() and @ownsVehicle and @model.get('value')? and !@model.get('accepted') and @model.get('user')?

  canShowCorrectionValidationHover: ->
    !@isEditing() and @ownsVehicle and @pendingCorrections and @pendingCorrections.size() != 0

  canShowHoverData: ->
    user = @model.get('user')
    return false unless user?
    @canShowValueSuggestedHover() or @canShowValueValidationHover() or @canShowCorrectionValidationHover()

  canShowMyPendingCorrection: ->
    !@isEditing() && !@ownsVehicle && @pendingCorrections &&
      (@pendingCorrections.size() > 0 or (@model.get('user') is @currentUser && !@model.get('accepted')?))

  myPendingCorrection: ->
    correction = @pendingCorrections.at(0)
    return correction if correction
    userSubmitted = @model.get('user')
    if userSubmitted is @currentUser and !@model.get('accepted')?
      @model

  myPendingCorrectionData: ->
    if @canShowMyPendingCorrection()
      return { myPendingCorrection: @myPendingCorrection() }
    { myPendingCorrection: null }

  hoverOverData: ->
    return {} unless @canShowHoverData()
    user = @model.get('user')
    data = {
      propertySourceAvatarUrl:   @propertySourceAvatarUrl(user)
      propertyCreatedAt:         @propertyCreatedAt(@model)
      propertySourceName:        @propertySourceName(user)
      showValueSuggestedHover:   @canShowValueSuggestedHover(),
      showValueValidationHover:  @canShowValueValidationHover()
    }
    if @canShowCorrectionValidationHover()
      correction = @pendingCorrections.at(0)
      user = correction.get('corrector')
      _.extend data,
        propertySourceAvatarUrl: @propertySourceAvatarUrl(user)
        propertyCreatedAt:  @propertyCreatedAt(correction)
        propertySourceName: @propertySourceName(user)
        propertySource: user
        valueAccepted: false
        propertyValue: correction.get('value')
        showCorrectionsPendingHover: true
        pendingCorrections: @pendingCorrections

    data

  propertySourceAvatarUrl: (user) ->
    user.get('avatar_url')

  propertyCreatedAt: (model) ->
    model.formattedCreatedAt()

  propertySourceName: (user) ->
    user.get('username')

  serializeData: ->
    $.extend {
        showControls:   @showControls,
        showCurrent:    @showCurrent,
        propertySource: @model.get('user'),
        valueAccepted:  @model.get('accepted'),
        modded:         @modded,
        value:          @model.get('value'),
        unit:           I18n.t(Seeds.propertyDefinitions[@model.get('name')], scope: 'units_new.unit_symbols') || ''
        isOwner:        Models.Ability.canManageVehicle(@vehicle),
        correctionFactor: @correction_factor
      },
      @serializeProperty(@model, 'property'),
      @serializeProperty(@stock_dependant_property, 'stockDependantProperty'),
      @serializeProperty(@currentProperty, 'currentProperty'),
      @serializeProperty(@current_dependant_property, 'currentDependantProperty'),
      @hoverOverData(),
      @myPendingCorrectionData()