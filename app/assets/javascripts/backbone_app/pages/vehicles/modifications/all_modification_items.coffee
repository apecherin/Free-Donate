#= require ./domain_modification_items.coffee

class Pages.Vehicles.Modifications.AllModificationItems extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/all_modification_items'

  regions:
    adContainer: '.ad-container'
    generalInfo: '.change-set-container'

  initialize: ({@modificationsByDomains, @versionProperties})->

  onRender: ->
    for domain, modifications of @modificationsByDomains
      if modifications.length
        new Pages.Vehicles.Modifications.DomainModificationItems(collection: modifications, versionProperties: @versionProperties, el: @$(".#{domain}-mod-container")).render()

    @adContainer.show new Pages.Ads.Ad_160x600
    @generalInfo.show new Pages.Vehicles.Modifications.ChangeSetGeneralInfo(model: @model)

  domainsWithModifications: ->
    domains = []
    for domain, mods of @modificationsByDomains
      domains.push domain if mods.length

    domains

  serializeData: ->
    modificationDomains: @domainsWithModifications()