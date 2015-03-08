class Modals.Users.UserInfo extends Backbone.Marionette.Layout
  template: 'modals/users/user_info'

  regions:
    follow: '#follow'

  events:
    'click input[name=user[rate]]' : 'saveRate'
    'click #report'                : 'saveReport'
    'click #block'                 : 'blockUser'
    'click #unlock'                : 'unblockUser'

  initialize: ({ @user, @current_user, @user_ratings, @user_oppositions }) ->
    @current_user.fetch success: (current_user)=>
      @current_user = current_user
      @user_oppositions = @current_user.get('user_oppositions')

  onRender: ->
    @current_user.get('followings').fetch success: (followings) =>
      @follow.show new Fragments.Users.Profile.Follow model: @user, followings: followings

  saveRate: (event) ->
    rating = new Models.Rating
    rating.set user_id: @user.get('id'), value: event.target.value
    rating.save null,
      success: =>
        if rating.isServerValid()
          MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: 'notification.rate')
        else
          @render()
      error: =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: 'notification.rate')

  saveReport: (event) ->
    report = new Models.Report
    report.set user_id: @user.get('id'), url: window.location.pathname
    report.save null,
      success: =>
        if report.isServerValid()
          event.target.remove()
          MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: 'notification.report')
        else
          if report.get('_errors')['user_id'] isnt 'undefined'
            MyApp.vent.trigger 'notify:error', I18n.t('already', scope: 'notification.report')
          @render()
      error: =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: 'notification.report')

  blockUser: ->
    user_opposition = new Models.UserOpposition
    user_opposition.set opposer_id: @user.get('id')
    user_opposition.save null,
      success: =>
        MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: 'notification.block')
        @user_oppositions.add(user_opposition)
        @render()
      error: =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: 'notification.block')

  unblockUser: ->
    user_opposition = @user_oppositions.find (oppos) => oppos.get('opposer_id') is @user.get('id')
    user_opposition.destroy
      success: =>
        MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: 'notification.unblock')
        @user_oppositions.remove(user_opposition)
        @render()
      error: =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: 'notification.unblock')

  serializeData: ->
    user: @user
    canRate: Models.Ability.canRate(@current_user.get('rating_info'))
    canAddToOpposers: @current_user and @user.get('id') isnt @current_user.get('id')
    userBlocked: @user_oppositions.find (oppos) => oppos.get('opposer_id') is @user.get('id')
    userRatings: @user_ratings
    currentUser: @current_user
    rating: @user.ratingNum()