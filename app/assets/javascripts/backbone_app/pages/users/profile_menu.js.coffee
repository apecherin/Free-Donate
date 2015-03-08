class Pages.Users.ShowProfileMenu extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/users/profile_menu"

  events:
    'click .edit-my-profile'       : 'goToEditMyProfile'
    'click .country-settings'      : 'goToEditMyCountry'
    'click .privacy-settings'      : 'goToEditMyPrivacy'
    

  initialize: ->
    @currentUser = Store.get('currentUser')
    unless @currentUser?
      @bindTo MyApp.vent, 'user:created', =>
        @currentUser = Store.get('currentUser')
        @render()

  goToEditMyProfile: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/info", true
    false

  goToEditMyCountry: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/geoloc", true
    false

  goToEditMyPrivacy: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/priva", true
    false