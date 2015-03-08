class Fragments.Vehicles.Specifications.Show extends Backbone.Marionette.Layout
  template: 'pages/vehicles/specifications/show'

  regions:
    adContainer: '.ad-container'

  events:
    'click .edit-properties' : 'editProperties'
    'click .view-properties' : 'viewProperties'

  initialize: ({@version, @dataSheet, @vehicle, @modifications, @importToolAvailable, @dataSheets})->

    @engineSpecNames =  ["energy", "cylinders", "displacement", "max_power", "max_power_frequency_from", "max_power_frequency_to", "max_torque", "max_torque_frequency_from", "max_torque_frequency_to"]
    @chassisSpecNames = ["weight", "length", "width", "height"]
    @activePropertyRequests = 0

    @collections = {}
    @showControls = false

    @bindTo MyApp.vent, "[specifications]fill-own", =>
      @importToolAvailable = false
      @showControls = true
      @render()

    @bindTo MyApp.vent, "[specifications]import-datasheet", (dataSheet)=>
      @importToolAvailable = @showControls = false
      @importDataSheet(dataSheet) if Models.Ability.canImportDataSheet(dataSheet)

  onRender: ->
    @adContainer.show new Pages.Ads.Ad_300x600
    if @importToolAvailable
      @renderImportTool()
    else if @activePropertyRequests == 0
      @renderView 'engine'
      @renderView 'chassis'
    MyApp.vent.trigger '[specifications]render', showControls: @showControls

  renderImportTool: ->
    new Fragments.Vehicles.Specifications.ImportTool(
      el:         @$("#import-tool")
      collection: @dataSheets
      model:      @vehicle
      version:    @version
      dataSheets: @dataSheets
    ).render()

  renderView: (group)->
    new Fragments.Vehicles.Specifications.Properties(
      el:            @$("#vehicle-#{group}-specs")
      collection:    @collections[group] || @buildProperties(group)
      showControls:  @showControls
      group:         group
      modifications: @modifications
      vehicle:       @vehicle
    ).render()
    if group is 'engine'
      callback = ->
#        from_tr = @$('tr.max_power_frequency_from')
#        value = from_tr.find('td.value')
#        modded = from_tr.find('td.modded')
#        to_tr_value = @$('tr.max_power')
#        @$('tr.max_power_frequency_to').remove()
#        @$('tr.max_torque_frequency_from').remove()
#        @$('tr.max_torque_frequency_to').remove()

      setTimeout(callback, 0)

  buildProperties: (group)->
    properties = new Collections.VersionProperties
    properties.version = @version
    for name in @["#{group}SpecNames"]
      property = @dataSheet.get name
      if typeof property isnt 'undefined'
        properties.add new Models.VersionProperty property
      else
        properties.add new Models.VersionProperty name: name
    @collections[group] = properties

  importDataSheet: (dataSheet)->
    @importGroup 'engine', dataSheet
    @importGroup 'chassis', dataSheet

  importGroup: (group, dataSheet)->
    @collections[group] = new Collections.VersionProperties
    @collections[group].version = @version
    for name in @["#{group}SpecNames"]
      if dataSheet.get(name)?
        property = new Models.VersionProperty name: dataSheet.get(name)["name"], value: dataSheet.get(name)["value"]
        property.collection = @collections[group]
        @activePropertyRequests += 1
        property.save {}, wait: true, success: (property) =>
          @activePropertyRequests -= 1
          @collections[group].add property
          @render()

  editProperties: ->
    @showControls = true
    @render()
    false

  viewProperties: ->
    @showControls = false
    @render()
    false

  serializeData: ->
    showControls:        @showControls
    importToolAvailable: @importToolAvailable
    is_owner: Models.Ability.canManageVehicle(@vehicle)
    currentUser: Store.get('currentUser')