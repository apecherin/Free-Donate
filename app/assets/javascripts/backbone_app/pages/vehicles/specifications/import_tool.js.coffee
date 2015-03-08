#= require ./same_vehicles_item

class Fragments.Vehicles.Specifications.ImportTool extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/specifications/import_tool'
  itemView: Fragments.Vehicles.Specifications.SameVehiclesItem

  events:
    'click .fill-own'          : 'fillOwn'
    'change .filter-attribute' : 'filterDataSheets'
    'click tbody tr'           : 'selectDataSheet'
    'click .import-datasheet'  : 'importDataSheet'
    'click .sortable'          : 'sortDatasheets'

  initialize: ({@version, @vehicle, @dataSheets})->
    @selectedDatasheetId = null

  onRender: ->
    callback = =>
      @$('.chosen').chosen(no_results_text: ' ')
    setTimeout callback, 0

  appendHtml: (collectionView, itemView)->
    collectionView.$('tbody').append(itemView.el)

  fillOwn: ->
    MyApp.vent.trigger "[specifications]fill-own"
    false

  filterDataSheets: ->
    name = @$('select[name=name]').val()
    production_year = @$('select[name=production_year]').val()
    market_version_name = @$('select[name=market_version_name]').val()
    @collection = @dataSheets.filter (dataSheet)->
      version = dataSheet.get('vehicle').get('version')

      (name is '' || name is version.get('name')) &&
        (production_year is '' || parseInt(production_year) is version.get('production_year')) &&
        (market_version_name is '' || market_version_name is version.get('market_version_name'))
    @renderCollection()
    false

  sortDatasheets: (e)->
    name = $(e.target).data('name')
    @collection = @collection.sortBy (dataSheet)=> dataSheet.get(name)?.value
    @renderCollection()
    false

  selectDataSheet: (e)->
    @$('tbody tr').removeClass('selected')
    tr = $(e.target).parents('tr')
    tr.addClass('selected')
    @selectedDatasheetId = tr.data('dataSheetId')
    @renderModel()
    false

  importDataSheet: ->
    if @selectedDatasheetId?
      MyApp.vent.trigger "[specifications]import-datasheet", @dataSheets.get(@selectedDatasheetId)
    false

  dataSheetValuesOf: (attribute)->
    _.uniq @dataSheets.map (dataSheet)=> dataSheet.get('vehicle').get('version').get(attribute)

  serializeData: ->
    vehicle:  @model
    brand:    @model.get('brand')
    model:    @model.get('model')
    versions: @dataSheetValuesOf('name')
    markets:  @dataSheetValuesOf('market_version_name')
    years:    @dataSheetValuesOf('production_year')
