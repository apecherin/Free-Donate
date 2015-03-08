#= require ./domain_modification_items

class Pages.Vehicles.Modifications.DomainModificationsLayout extends Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/category_modifications_layout'

  regions:
    adContainer:            '.ad-container'
    modificationsContainer: '.modification-container'

  events:
    'click .add-modification' : 'addModification'
    'click .import-modifications' : 'importModifications'

  initialize: ({@modifications, @domain, @change_set, @versionProperties})->
    @user = @change_set.get('vehicle')?.get('user')
    @bindTo MyApp.vent, 'modification:imported', =>
      Backbone.history.navigate "#{Routers.Main.showModificationsConfPath(@change_set.get('vehicle'), @change_set)}", true

  onRender: ->
    @adContainer.show new Pages.Ads.Ad_160x600
    @modificationsContainer.show new Pages.Vehicles.Modifications.DomainModificationItems collection: @modifications, versionProperties: @versionProperties

  addModification: ->
    @$('.mods-actions').addClass 'disable-mods-actions'
    @modifications.add new Models.Modification domain: @domain, change_set: @change_set, vehicle: @change_set.get('vehicle')
    false

  importModifications: ->
    modifications = new Collections.UserModifications
    modifications.fetch data: {user_id: @user.id, type: 'my_saves'}, success: (modifications) =>
      MyApp.modal.show new Modals.ImportModifications
        user: @user
        vehicle: @change_set.get('vehicle')
        change_set_id: @change_set.id
        domain: @domain
        modifications: modifications
    false

  serializeData: ->
    showControls: Models.Ability.canManageChangeSet(@change_set)