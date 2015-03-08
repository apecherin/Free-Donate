class Fragments.Users.Profile.Rate extends Backbone.Marionette.ItemView
  template: 'fragments/users/profile/rate'

  events:
    'click .rate' : 'rate'

  initialize: ({@user, @rating_info, @can_manage, @can_add_to_opposers})->
    @currentUser = Store.get('currentUser')

  rate: ->
    @user.fetch success: (user) =>
      MyApp.modal.show new Modals.Users.UserInfo
        user: user
        current_user: @currentUser
        user_ratings: user.get('ratings')
        user_oppositions: @currentUser.get('user_oppositions')
    false

  serializeData: ->
    canManage: @can_manage
