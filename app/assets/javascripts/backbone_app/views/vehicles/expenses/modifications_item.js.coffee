class Fragments.Expenses.ModificationsItem extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/expenses/modifications_item'
  className: 'modification-container'

  initialize: ({@model}) ->
    @totalCostManHours = 0
    @totalCostParts = 0
    @services = @model.get('services')
    @part_purchases = @model.get('part_purchases')
    @currentCurrencyRate = Store.get('current_currency_rate')

    tcmh = @part_purchases.pluck("price")
    total_cost_parts = if tcmh.length > 0 then tcmh.reduce((a, b) -> parseFloat(a) + (if b is null then 0 else parseFloat(b))) else 0
    @totalCostParts = parseFloat(total_cost_parts)

    total_cost_man_hours = 0
    @services.each (service) ->
      total_cost_man_hours = total_cost_man_hours + (service.get('hourly_rate') * service.get('duration'))
    @totalCostManHours = total_cost_man_hours

  onRender: ->

  serializeData: ->
    modification: @model
    currentCurrencyRate: @currentCurrencyRate
    totalCostParts: if @totalCostParts is 0 then 0 else @totalCostParts.toFixed(2)
    totalCostManHours: if @totalCostManHours is 0 then 0 else @totalCostManHours.toFixed(2)