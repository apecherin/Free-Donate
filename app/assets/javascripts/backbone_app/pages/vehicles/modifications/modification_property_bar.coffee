class Pages.Vehicles.Modifications.ModificationPropertyBar extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/modification_property_bar'
  className: 'modification-property-bar-container'

  initialize: ({@versionProperties})->
    @stockProperty = @versionProperties.findByName @model.get('name')
    @stockProperty = if @stockProperty? then @stockProperty else {value: 1}
    @isStringProperty = @model.get('name') in ['energy', 'cylinders']
    stock_value = if !@stockProperty? then 0 else @stockProperty['value'] || @stockProperty.value || @stockProperty.get('value')
    @gain = if @isStringProperty then 100 else ((@model.get('value') - stock_value) / stock_value * 100)
    @good_results = {'light': '#ccff00', 'medium': '#99ff00', 'strong': '#33cc33'}
    @bad_results = {'light': '#ffcc00', 'medium': '#ff9900', 'strong': '#ff6600'}
    @color = @getColorBar()

  getColorBar: ->
    value = @gain.toFloatTry()
    bads = ['weight', 'consumption_city', 'consumption_highway', 'consumption_mixed',
            'CO2_emissions', 'accel_time_0_60_kph', 'accel_time_0_100_kph', 'accel_time_0_160_kph',
            'accel_time_0_200_kph', 'accel_time_0_300_kph', 'accel_time_100_200_kph',
            'accel_time_200_300_kph', 'accel_time_0_96_kph', 'accel_time_96_209_kph',
            'engine', 'max_power_frequency_from', 'max_power_frequency_to',
            'max_torque_frequency_from', 'max_torque_frequency_to']

    if @model.get('name') in bads
      if value >= 0 && value < 7
        @bad_results['light']
      else if value >= 7 && value < 13
        @bad_results['medium']
      else
        @bad_results['strong']
    else
      if value >= 0 && value < 3.1
        @good_results['light']
      else if value >= 3.1 && value < 7
        @good_results['medium']
      else
        @good_results['strong']

  serializeData: ->
    property: @model
    isStringProperty: @isStringProperty
    stockProperty: @stockProperty
    gain: @gain
    color: @color