class Fragments.Vehicles.Identification extends Backbone.Marionette.Layout
  template: 'fragments/vehicles/identification'

  regions:
    picture: '#picture'
    version: '#version'

  events:
    'click .show-identification_show' : 'showIdentificationShowMode'

  initialize: ({@versionAttributes, @generations})->
    @bindTo MyApp.vent, '[version]change:transmission_type', =>
      @picture.show new Fragments.Vehicles.Identification.Picture model: @model

  onRender: ->
    @picture.show new Fragments.Vehicles.Identification.Picture model: @model
    @version.show new Fragments.Vehicles.Identification.Version
      model:             @model.get('version')
      vehicle:           @model
      versionAttributes: @versionAttributes
      generations:       @generations

  showIdentificationShowMode: (e) ->
    $('.vehicle-tabs').find('.show-identification_show').click()
    false

  serializeData: ->
    vehicle: @model
    showIdentificationShowLink: @model.get('version')?.get('full_identity_data')
