class Pages.Vehicles.Expenses.ModificationInfo extends Backbone.Marionette.Layout
  template: 'pages/vehicles/expenses/tab_info/modification_info'

  regions:
    'modifications_list' : '#modifications'

  initialize: ({@modifications})->
    @currentCurrencyRate = Store.get('current_currency_rate')
    @totalCostParts = 0
    @totalCostManHours = 0

    @modifications.each (modification) =>
      @services = modification.get('services')
      @part_purchases = modification.get('part_purchases')

      tcmh = @part_purchases.pluck("price")
      total_cost_parts = if tcmh.length > 0 then tcmh.reduce((a, b) -> parseFloat(a) + (if b is null then 0 else parseFloat(b))) else 0
      @totalCostParts = @totalCostParts + parseFloat(total_cost_parts)

      total_cost_man_hours = 0
      @services.each (service) ->
        total_cost_man_hours = total_cost_man_hours + (service.get('hourly_rate') * service.get('duration'))
      @totalCostManHours = @totalCostManHours + parseFloat(total_cost_man_hours)

  onRender: ->
    @modifications_list.show new Fragments.Expenses.Modifications
      collection: @modifications

  serializeData: ->
    totalCostParts: @totalCostParts
    totalCostManHours: @totalCostManHours
    currentCurrencyRate: @currentCurrencyRate