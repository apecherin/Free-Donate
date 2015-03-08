class Fragments.Vehicles.Identification.Ownership extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/ownership'

  events:
    'change .ownership-attribute' : 'saveOwnership'

  initialize: ->
    @bindTo @model, 'change:status', @render

  onRender: ->
    callback = =>
      @$('.chosen').chosen(no_results_text: ' ')
    setTimeout callback, 0

  collectData: ->
    year:       @$('#ownership_year').val()
    owner_name: @$('#ownership_owner_name_id').val()
    status:     @$('#ownership_status_id').val()

  saveOwnership: ->
    @model.set @collectData()
    @model.save null, wait: true

  ownershipYears: ->
    _.range(1950, (new Date().getFullYear() + 1)).reverse()

  serializeData: ->
    ownership:    @model
    statuses:     @model.get('statuses')
    owner_names:  @model.get('owner_names')
    showControls: Models.Ability.canManageVehicle(@model.get('vehicle'))
    ownershipYears: @ownershipYears()
