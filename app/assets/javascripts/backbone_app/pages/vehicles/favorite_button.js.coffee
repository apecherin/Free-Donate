class Fragments.Vehicles.FavoriteButton extends Backbone.Marionette.Layout
  template: 'fragments/vehicles/favorite_button'

  events:
    'click .add-bookmark'        : 'addToBookmarks'
    'click .remove-bookmark'     : 'removeFromBookmarks'

  addToBookmarks: Views.Mixins.addToBookmarks
  removeFromBookmarks: Views.Mixins.removeFromBookmarks
  updateBookmarkAbilities: Views.Mixins.updateBookmarkAbilities

  initialize: ({@vehicle, @vehicleType})->
    @currentUser = Store.get('currentUser')
    if @currentUser?
      @bookmarkedVehicles = @currentUser.get('bookmarkedVehicles')
      @bookmarkedVehicles.onReset => @updateBookmarkAbilities()

  onRender: ->

  serializeData: ->
    canAddToBookmarks: !@canRemoveFromBookmarks
    vehicleType: @vehicleType
