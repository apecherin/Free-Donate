class Pages.Vehicles.SelectComparison extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/vehicles/comparison_menu"

  events:
    'click .vehicles-follow'       : 'goToVehicleFollow'    
    'click .sales-follow'          : 'goToSalesFollow'
    'click .comparison-likes'      : 'goToComparisonLikes'
    'click .pin-likes'             : 'goToPinLikes'

  goToPinLikes:->
    false

  goToVehicleFollow:->
    Backbone.history.navigate Routers.Main.vehicleFollowPath(), true
    false

  goToSalesFollow:->
    Backbone.history.navigate Routers.Main.SalesFollowPath(), true
    false

  goToComparisonLikes:->
    Backbone.history.navigate Routers.Main.ComparisonLikesPath(), true
    false