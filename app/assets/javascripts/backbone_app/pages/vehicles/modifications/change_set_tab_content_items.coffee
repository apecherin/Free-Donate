#= require ./change_set_tab_content_item

class Pages.Vehicles.Modifications.ChangeSetTabContentItems extends Backbone.Marionette.CollectionView
  className: 'tab-content'
  itemView: Pages.Vehicles.Modifications.ChangeSetTabContentItem

  initialize: ({@versionProperties, @currentDomainName, @currentModificationId, @currentChangeSet, @currentPurchasePictureId, @cps_tab})->

  onRender: ->
    @currentChangeSet = @currentDomainName = @currentModificationId = @currentPurchasePictureId = @cps_tab = null

  itemViewOptions: ->
    versionProperties: @versionProperties
    currentDomainName: @currentDomainName
    currentModificationId: @currentModificationId
    currentChangeSet: @currentChangeSet
    currentPurchasePictureId: @currentPurchasePictureId
    cps_tab: @cps_tab