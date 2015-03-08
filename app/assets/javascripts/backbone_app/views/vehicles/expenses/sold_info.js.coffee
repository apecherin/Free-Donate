class Fragments.Expenses.SoldInfo extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/expenses/sold_info'

  events:
    'click .go-to-user' : 'goToUser'

  initialize: ({@modeEdit, @vehiclePrice, @users})->
    @currentCurrencyRate = Store.get('current_currency_rate')

  onRender: ->
    @currentCurrencyRate = if @vehiclePrice.get('sold_price')? then Store.get('current_currency_rate') else @vehiclePrice.get('currency_rate')[Store.get('currentCurrency').toLowerCase()]
    if @modeEdit
      @$('.buyer_id').chosen()
    else
#      @setOdometerValue('.sold_odometer', @vehiclePrice.get('sold_odometer'))

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

  goToUser: (e) ->
    userId = $(e.currentTarget).data('user-id')
    userId ||= @model.get('initiator').id
    Backbone.history.navigate Routers.Main.showUserProfilePath(userId), true
    false

  serializeData: ->
    modeEdit: @modeEdit
    vehiclePrice: @vehiclePrice
    users: @users
    currentCurrencyRate: @currentCurrencyRate