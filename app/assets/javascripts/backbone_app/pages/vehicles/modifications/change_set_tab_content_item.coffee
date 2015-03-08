#= require ./domain_modifications_layout
#= require ./detailed_modification_item

class Pages.Vehicles.Modifications.ChangeSetTabContentItem extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/change_set_item'
  className: 'tab-pane change-set-tab-content'

  events:
    'click .domain-tab'             : 'showDomainTab'
    'click .modification-name'      : 'showModification'
    'click .back'                   : 'returnBack'

  regions:
    tabContainer: '#change-set-tab-content'

  initialize: ({@versionProperties, @currentDomainName, @currentModificationId, @currentChangeSet, @currentPurchasePictureId, @cps_tab})->
    @modificationDomains = Models.Modification.domains()

    @modificationsByDomains = @modificationDomains.reduce (acc, domain)=>
      acc[domain] = new Collections.Modifications @model.get('modifications').filter (modification)-> modification.get('domain') is domain
      acc
    , {}

    if @currentChangeSet? && @currentDomainName? && @model.get('name') isnt @currentChangeSet.get('name')
      @currentDomainName = @currentModificationId = null

  onRender: ->
    @$el.attr('id', "change_set_#{@model.id}")
    if @currentDomainName?
      @showDomainTab target: ".domain-tab.#{@currentDomainName}"
    else
      @showDomainTab target: '.domain-tab.all_mods', false

  showDomainTab: (e, not_after_render=true)->
    domain = @$(e.target).data('domain')
    modifications = @modificationsByDomains[domain]
    options = {}
    options['change_set'] = @model
    options['domain_name'] = ''
    if typeof(modifications) isnt 'undefined'
      @tabContainer.show new Pages.Vehicles.Modifications.DomainModificationsLayout modifications: modifications, domain: domain, change_set: @model, versionProperties: @versionProperties
      if not_after_render
        options['domain_name'] = domain
        MyApp.vent.trigger 'domain:choice', 'modifications', options
        if @currentDomainName?
          @$('ul.nav-tabs').find('li').removeClass('active')
          @$("[data-domain='#{@currentDomainName}']").parent('li').addClass('active')
          @currentDomainName = null
          if @currentModificationId?
            @showModification(null, @currentModificationId)
            @currentModificationId = null
        else
          Backbone.history.navigate Routers.Main.showModificationsConfDomainPath(@model.get('vehicle'), @model, domain)
    else
      @tabContainer.show new Pages.Vehicles.Modifications.AllModificationItems modificationsByDomains: @modificationsByDomains, versionProperties: @versionProperties, model: @model
      if not_after_render
        MyApp.vent.trigger 'domain:choice', 'modifications', options
        Backbone.history.navigate Routers.Main.showModificationsConfPath(@model.get('vehicle'), @model)
    @currentChangeSet = @currentDomainName = @currentModificationId = @currentPurchasePictureId = null

  showModification: (e, mod_id=null)->
    options = {}
    target_id = if mod_id? then mod_id else @$(e.target).data('id')
    modification = @model.get('modifications').get target_id
    return false if !modification? || (modification?.get('state') is 'private' && modification?.get('user').id isnt Store.get('currentUser')?.id)
    if @$("[data-domain='all_mods']").parent('li').hasClass('active')
      @$('ul.nav-tabs').find('li').removeClass('active')
      @$("[data-domain='#{modification.get('domain')}']").parent('li').addClass('active')
    options['change_set'] = @model
    options['domain_name'] = modification.get('domain')
    options['modification'] = modification

    @tabContainer.show new Pages.Vehicles.Modifications.DetailedModificationItem
      model: modification
      versionProperties: @versionProperties
      cps_tab: @cps_tab
      currentPurchasePictureId: @currentPurchasePictureId

    MyApp.vent.trigger 'modification:choice', 'modifications', options
    if !mod_id?
      Backbone.history.navigate Routers.Main.showModificationsConfDomainModPath(@model.get('vehicle'), @model, modification.get('domain'), modification)

    @currentChangeSet = @currentDomainName = @currentModificationId = @cps_tab = @currentPurchasePictureId = null
    false

  returnBack: ->
    @$('li.active .domain-tab').click()
    false

  serializeData: ->
    modificationDomains:    @modificationDomains
    changeSet: @model