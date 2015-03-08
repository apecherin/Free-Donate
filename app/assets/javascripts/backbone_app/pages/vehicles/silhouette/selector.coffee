#= require ./selector_item
#= require ./selector_empty

class Fragments.Vehicles.SilhouetteSelector extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/silhouette/selector'
  itemView: Fragments.Vehicles.SilhouetteSelectorItem
  emptyView: Fragments.Vehicles.SilhouetteSelectorEmpty

  itemViewOptions: ->
    vehicle: @vehicle

  events:
    'change #svf_production_year, #svf_market_version_name, #svf_production_code': 'filterCollection'
    'click .side-view-list-item a' : 'selectSideView'

  initialize: ({@sideViews, @vehicle})->
    @defaultYears  = @sideViews.map((sideView)-> sideView.get('version').get('production_year')).unique()
    @marketVersionNames = @sideViews.map((sideView)-> sideView.get('version').get('market_version_name')).unique()
    @productionCodes = @sideViews.map((sideView)-> sideView.get('version').get('production_code')).unique()


  filterCollection: ->
    @collection = @sideViews.filter (sideView)=>
      version = sideView.get('version')

      selectedProductionYear = @productionYearSelect.val()
      selectedMarketVersionName = @marketVersionNameSelect.val()
      selectedProductionCode = @productionCodeSelect.val()

      (selectedProductionYear is '' || selectedProductionYear is version.get('production_year').toString()) and (selectedMarketVersionName is '' || selectedMarketVersionName is version.get('market_version_name')) and (selectedProductionCode is '' || selectedProductionCode is version.get('production_code'))

    @renderCollection()

  onRender: ->
    @productionYearSelect = @$('#svf_production_year')
    @marketVersionNameSelect = @$('#svf_market_version_name')
    @productionCodeSelect = @$('#svf_production_code')

    @$('.chosen').chosen
      no_results_text: ' '
      allow_single_deselect: true

  selectSideView: (e)->
    @$('.side-view-list-item').removeClass('selected')

    $target = @$(e.currentTarget)
    unless $target.hasClass('current')
      $target.parents('.side-view-list-item').addClass('selected')

    false

  appendHtml: (collectionView, itemView)->
    $list = collectionView.$('#side-view-list')
    $list.append(itemView.el)

  serializeData: ->
    years:              @defaultYears
    marketVersionNames: @marketVersionNames
    productionCodes:    @productionCodes