class Pages.MyyCloud.ShowHarddriveMenu extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/myy_cloud/show_hard_drive"

  events:
    'click .imported-content'      : 'goToImportedContent'
    'click .my-public-albums'      : 'goToMyPublicAlbums'
    'click .my-private-albums'     : 'goToMyPrivateAlbums'
    'click .installation'          : 'goToMyInst'
    

  initialize: ->
    @currentUser = Store.get('currentUser')
    unless @currentUser?
      @bindTo MyApp.vent, 'user:created', =>
        @currentUser = Store.get('currentUser')
        @render()

  goToImportedContent: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('imp', @currentUser), true
    false

  goToMyPublicAlbums: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('pub', @currentUser), true
    false

  goToMyPrivateAlbums: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('priv', @currentUser), true
    false

  goToMyInst: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('inst', @currentUser), true
    false