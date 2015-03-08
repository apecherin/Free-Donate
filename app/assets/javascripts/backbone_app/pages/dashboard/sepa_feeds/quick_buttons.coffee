class Pages.Dashboard.QuickButtons extends Backbone.Marionette.Layout
  template: 'pages/dashboard/sepa_news_feeds/quick_buttons'

  events:
    'click .add-vehicle': 'addVehicle'
    'click .upload-pictures': 'uploadPictures'
    'click .get-m5-button': 'getM5Button'

  initialize: ({  })->
    @currentUser = Store.get('currentUser')

  onRender: ->

  addVehicle: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showNewVehiclesPath(), true
    else
      Backbone.history.navigate Routers.Main.loginPath(), true

  uploadPictures: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserProfilePath(@currentUser), true
    else
      Backbone.history.navigate Routers.Main.loginPath(), true

  getM5Button: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.myyCloudPath('inst', @currentUser), true
    else
      Backbone.history.navigate Routers.Main.loginPath(), true