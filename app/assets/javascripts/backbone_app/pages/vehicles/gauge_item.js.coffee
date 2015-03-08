class Fragments.Vehicles.GaugeItem extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/gauge_item'
  className: 'gauge'

  initialize: ({@model})->
    @max_value = @model.get('max_value') - 0
    @current_value = @model.get('value')
    @current_unit = @model.get('name')

  onRender: ->
    if (typeof @current_value == 'string' || @current_value instanceof String)
      return false
    else
      opts = {
        lines: 15,
        angle: 0.25,
        lineWidth: 0.15,
        pointer: {
          length: 0.9,
          strokeWidth: 0.035,
          color: '#000000'
        },
        limitMax: 'false',
        colorStart: '#6F6EA0',
        colorStop: '#C0C0DB',
        strokeColor: '#EEEEEE',
        generateGradient: true
      };

      target = @$("#gauge-#{@model.id}").get(0);
      gauge = new Donut(target).setOptions(opts);
      gauge.maxValue = @max_value;
      gauge.animationSpeed = 100;
      gauge.set(@current_value);
      gauge.setTextField(@$("#gauge-value-#{@model.id}").get(0));

  serializeData: ->
    model: @model
    currentUnit: @current_unit
    unit: I18n.t(Seeds.propertyDefinitions[@model.get('name')], scope: 'units_new.unit_symbols') || ''