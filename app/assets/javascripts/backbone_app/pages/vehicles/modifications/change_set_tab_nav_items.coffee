#= require ./change_set_tab_nav_item

class Pages.Vehicles.Modifications.ChangeSetTabNavItems extends Backbone.Marionette.CompositeView
  itemView: Pages.Vehicles.Modifications.ChangeSetTabNavItem
  template: 'pages/vehicles/modifications/change_set_tab_nav_items'

  events:
    'click .add-new-change-set' : 'addChangeSet'

  initialize: ({@changeSets, @vehicle}) ->

  appendHtml: (collectionView, itemView)->
    collectionView.$('.add-new-change-set').before itemView.el

  addChangeSet: ->
    MyApp.modal.show new Pages.Vehicles.Modifications.ChangeSetsNew changeSets: @collection
    false

  serializeData: ->
    is_owner: Models.Ability.canManageVehicle(@vehicle)