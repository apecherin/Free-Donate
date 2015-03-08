#= require ./version_comment_item
Fragments.Vehicles.VersionComments = Backbone.Marionette.CompositeView.extend
  template: 'fragments/vehicles/version_comments'
  itemView: Fragments.Vehicles.VersionCommentItem

  initialize: ({})->
    @canManage = Models.Ability.canManageVehicle @model.get('vehicle')

  serializeData: ->
    canManage: @canManage
