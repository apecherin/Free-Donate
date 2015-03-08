class Fragments.Vehicles.Modifications.AvailablePartPurchases extends Backbone.Marionette.Layout
  template: 'fragments/modifications/available_part_purchases'

  initialize: ({@partPurchase}) ->
    @bindTo MyApp.vent, 'available_categories:changed', @changeCategoriesEvent
    @parts = @partPurchase.availableParts()
    @category = @partPurchase.get('category') || @partPurchase.availableCategories()[0]
    if @parts.length is 0
      @parts = @partPurchase.availablePartsByCategory(@category)

  changeCategoriesEvent: (new_category) ->
    @parts = @partPurchase.availablePartsByCategory(new_category)
    @category = new_category
    @render()

  onRender: ->

  serializeData: ->
    partPurchase: @partPurchase
    modification: @partPurchase.get('modification')
    parts: @parts
    category: @category
