class Pages.Vehicles.Modifications.ChangeSetTabNavItem extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/change_set_tab_nav_item'
  tagName: 'li'

  events:
    'click a' : 'choiceChangeSet'

  choiceChangeSet: ->
    options = {}
    options['change_set'] = @model
    MyApp.vent.trigger 'change_set:choice', 'modifications', options
    Backbone.history.navigate Routers.Main.showModificationsConfPath(@model.get('vehicle'), @model)

  serializeData: ->
    change_set: @model