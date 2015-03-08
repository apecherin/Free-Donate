class Fragments.Vehicles.Modifications.AvailableCategories extends Backbone.Marionette.Layout
  template: 'fragments/modifications/available_categories'

  events:
    'change select.current_categories': 'changeCurrentCategory'

  initialize: ({@partPurchase}) ->

  onRender: ->

  changeCurrentCategory: (e) ->
    $target = $(e.target)
    MyApp.vent.trigger 'available_categories:changed', $target.val()

  serializeData: ->
    partPurchase: @partPurchase
    modification: @partPurchase.get('modification')
    categories: @partPurchase.availableCategories()
