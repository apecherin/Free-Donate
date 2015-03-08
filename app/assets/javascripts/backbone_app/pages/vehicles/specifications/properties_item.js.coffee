class Fragments.Vehicles.Specifications.PropertiesItem extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/specifications/properties_item'
  tagName: 'tr'

  events:
    'change .property-value'               : 'changeValue'
    'click .inactive .unit-alternate-link' : 'changeUnit'

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)
    @$el.attr('class', @model.get('name'))

  initialize: ({@showControls, @modifications, @vehicle})->
    @mods_values = []
    @modded = @modifications.reduce((memo, modification)=>
      property = modification.get('properties').find (property)=> property.get('name') is @model.get('name')
      if property? and property.stringProperty()
        property.get('value')
      else
        if property? and property.get('value')?
          @mods_values.push(property.get('value'))
          memo + property.get('value')
        else
          memo
    , 0)
    @correction_factor = @model.get('correction_factor')
    @modded = @calcModsValue(@mods_values, @model)
    @currentUser = Store.get('currentUser')
    @hpShow = true
    @kwShow = false
    @NmShow = true
    @kgmShow = false
    @bindTo MyApp.vent, '[specifications]render', (options) =>
      @render()

  calcModsValue: (mods_values, stock) ->
    return false if mods_values.length is 0 || stock is 'undefined' || stock.get('name') in ['energy', 'cylinders']
    sum_mods_values = mods_values.reduce (a, b) -> a + b
    value = sum_mods_values - ((mods_values.length - 1) * stock.get('value'))
    @correction_factor = if @correction_factor in ['', null, undefined] then 0 else @correction_factor
    value + @correction_factor.toNumber()

  changeValue: (e) ->
    @model.set @collectData($(e.target))
    @model.save({})
    false

  unitTranslationTable:
    'hp to kw'  : (hp)  -> hp / 1.36
    'kw to hp'  : (kw)  -> kw * 1.36
    'Nm to kgm' : (nm)  -> nm * 0.0981
    'kgm to Nm' : (kgm) -> kgm / 0.0981

  changeUnit: (e) ->
    $target = $(e.currentTarget)
    from = $target.data('unit-alternate-from')
    to   = $target.data('unit-alternate-to')
    this["#{from}Show"] = false
    this["#{to}Show"]   = true
    oldData = @collectDataRaw()
    newData = Math.round(@unitTranslationTable["#{from} to #{to}"](oldData) * 100) / 100
    @unitValue = newData
    @render()
    false

  collectDataRaw: (source) ->
    source.val().replace(',', '.')

  collectData: (source) ->
    val = @collectDataRaw(source)
    if source.attr('name') is 'correction_factor'
      { correction_factor: val, vehicle_id: @vehicle.id }
    else
      if @kwShow
        val = @unitTranslationTable['kw to hp'](val)
      if @kgmShow
        val = @unitTranslationTable['kgm to Nm'](val)
      { value: val, vehicle_id: @vehicle.id }

  serializeData: ->
    showControls: @showControls
    propertyName: @model.get('name')
    value:        @unitValue || @model.get('value')
    unit:         I18n.t(Seeds.propertyDefinitions[@model.get('name')], scope: 'units_new.unit_symbols') || ''
    modded:       @modded
    isEditing:    @$('.property-value').length isnt 0
    kwShow:       @kwShow
    kgmShow:      @kgmShow
    isOwner:      Models.Ability.canManageVehicle(@vehicle)
    correctionFactor: @correction_factor
