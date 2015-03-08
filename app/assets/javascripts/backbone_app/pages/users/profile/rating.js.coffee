class Fragments.Users.Profile.Rating extends Backbone.Marionette.ItemView
  template: 'fragments/users/profile/rating'

  initialize: ({@user})->

  serializeData: ->
    rating: @user.ratingNum()
