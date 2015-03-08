class Fragments.Vehicles.SaveComparisonButton extends Backbone.Marionette.Layout
  template: 'fragments/vehicles/save_comparison_button'

  events:
    'click .save-compare' : 'showCompareBox'

  showCompareBox: Views.Mixins.showCompareBox

  initialize: ({@vehicle})->

  onRender: ->

  saveComparison: ->
    alert 'need implement'
    false

  serializeData: ->