Views.Mixins.showCompareBox = ->
  comparisonTables = new Collections.ComparisonTables
  comparisonTables.fetch data: {page: 1}, success: =>
    modal = new Pages.Vehicles.CompareModal vehicle: @vehicle, comparisonTables: comparisonTables
    MyApp.modal.show modal
  false

Views.Mixins.addToBookmarks = ->
  return false if Models.Ability.canManageVehicle(@vehicle) || !Store.get('currentUser')?
  vehicleBookmark = new Models.VehicleBookmark(vehicle: @vehicle)
  vehicleBookmark.save {}, {
    success: (model, response) =>
      @bookmarkedVehicles.add model.get('vehicle'), at: 0
      @updateBookmarkAbilities()
  }
  false

Views.Mixins.updateBookmarkAbilities = ->
  bookmarkedVehicleIds    = @bookmarkedVehicles.pluck('id')
  @canRemoveFromBookmarks = _.contains bookmarkedVehicleIds, @vehicle.id
  @render()

Views.Mixins.removeFromBookmarks = ->
  return false if Models.Ability.canManageVehicle(@vehicle) || !Store.get('currentUser')?
  vehicleBookmark = new Models.VehicleBookmark(id: @vehicle.id, vehicle: @vehicle)
  vehicleBookmark.destroy success: (model, response) =>
    @bookmarkedVehicles.remove(@vehicle)
    @updateBookmarkAbilities()
  false
