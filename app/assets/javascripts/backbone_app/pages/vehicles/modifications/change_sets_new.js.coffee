class Pages.Vehicles.Modifications.ChangeSetsNew extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/change_sets_new'
  events:
    'click .save-change-set' : 'saveChangeSet'

  initialize: ({@changeSets})->

  onRender: ->
    @$('#new-change-set-name').on 'keydown', (e) =>
      @keyHandler(e)

  keyHandler: () ->
    event.stopPropagation()
    if event.which is 13
      @saveChangeSet()
      event.preventDefault()

  saveChangeSet: ->
    changeSet = new Models.ChangeSet @collectData()
    changeSet.collection = @changeSets
    changeSet.save {},
      wait: true
      success: (model, response)=>
        options = {}
        @changeSets.add model
        options['change_set'] = model
        MyApp.vent.trigger 'change_set:choice', 'modifications', options
        Backbone.history.navigate Routers.Main.showModificationsConfPath(model.get('vehicle'), model)
        @close()

    false

  collectData: ->
    name: @$('#new-change-set-name').val()