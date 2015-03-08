class Fragments.Expenses.SellingInfo extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/expenses/selling_info'

  initialize: ({@modeEdit, @vehiclePrice})->
    @currentCurrencyRate = Store.get('current_currency_rate')

  onRender: ->
    @currentCurrencyRate = if @vehiclePrice.get('selling_price')? then Store.get('current_currency_rate') else @vehiclePrice.get('currency_rate')[Store.get('currentCurrency').toLowerCase()]
#    unless @modeEdit
#      @setOdometerValue('.selling_odometer', @vehiclePrice.get('selling_odometer'))

  setOdometerValue: (odometer_class, value) ->
    setTimeout (->
      el = $(odometer_class)
      od = new Odometer(
        el: el[0]
        value: 0
      )
      od.update value

      setTimeout (->
        odometer_zero_digit = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"><span class="odometer-ribbon"><span class="odometer-ribbon-inner"><span class="odometer-value">0</span></span></span></span></span>'
        inside = $(odometer_class + ' .odometer-inside')
        current_digit_count = inside.find('.odometer-digit').length
        diff = window.odometerOptions.min_count - current_digit_count

        n = 0
        while n < diff
          n++
          inside.prepend(odometer_zero_digit)
      ), 2200
    ), 100

  serializeData: ->
    modeEdit: @modeEdit
    vehiclePrice: @vehiclePrice
    currentCurrencyRate: @currentCurrencyRate