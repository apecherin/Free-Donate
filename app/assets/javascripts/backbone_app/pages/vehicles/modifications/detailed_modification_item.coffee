#= require ./modification_purchases
#= require ./modification_properties
#= require ./modification_item

class Pages.Vehicles.Modifications.DetailedModificationItem extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/detailed_modification_item'

  regions:
    modificationContainer:        '.modification-container'
    purchasesServiceContainer:    '.purchases-services-container'
    purchasesPartContainer:       '.purchases-parts-container'
    propertiesSeparatorContainer: '.properties-separator-container'

  events:
    'click .cps-tab' : 'activateNewTab'

  initialize: ({@versionProperties, @currentPurchasePictureId, @cps_tab})->
    @bindTo MyApp.vent, 'modification:mode_edit:active', @editModeActive
    @bindTo MyApp.vent, 'modification:mode_edit:deactive', @editModeDeactive
    @currentTab = if @cps_tab? then @cps_tab else 'changes'

  onRender: ->
    _.defer =>
      @activateTab()
    @$el.addClass HAML.globals()['domId'](@model)
    services = new Backbone.Collection
    parts = new Backbone.Collection
    parts.add @model.get('part_purchases').models
    services.add @model.get('services').models

    @modificationContainer.show new Pages.Vehicles.Modifications.ModificationItem model: @model
    @purchasesServiceContainer.show new Pages.Vehicles.Modifications.ModificationPurchases collection: services, modification: @model, currentPurchasePictureId: @currentPurchasePictureId, cps_tab: @cps_tab, typeItems: 'services'
    @purchasesPartContainer.show new Pages.Vehicles.Modifications.ModificationPurchases collection: parts, modification: @model, currentPurchasePictureId: @currentPurchasePictureId, cps_tab: @cps_tab, typeItems: 'parts'
    @propertiesSeparatorContainer.show new Pages.Vehicles.Modifications.ModificationSeparatorProperties collection: @model.get('properties'), modification: @model, versionProperties: @versionProperties

    @currentPurchasePictureId = @cps_tab = null


  editModeActive: ->
    $('.edit-mod-button').hide()

  editModeDeactive: ->
    $('.edit-mod-button').show()

  activateNewTab: (e) ->
    e.preventDefault()
    $target = $(e.currentTarget)
    tabName = $target.data('tab-name')
    @currentTab = tabName
    @activateTab()

  activateTab: ->
    $tab = @$("a[href=##{@currentTab}]")
    $tab.tab 'show'
    options = {}
    options['change_set'] = @model.get('change_set')
    options['domain_name'] = @model.get('domain')
    options['modification'] = @model
    options['cps_tab'] = @currentTab
    MyApp.vent.trigger 'cps_tab:choice', 'modifications', options
    unless @currentPurchasePictureId?
      Backbone.history.navigate Routers.Main.showModificationsConfDomainModCPSPath(@model.get('vehicle'), @model.get('change_set'), @model.get('domain'), @model, @currentTab)

