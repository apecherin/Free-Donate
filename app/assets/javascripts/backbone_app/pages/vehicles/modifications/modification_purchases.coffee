#= require ./modification_part
#= require ./modification_service

class Pages.Vehicles.Modifications.ModificationPurchases extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/modifications/modification_purchases'
  events:
    'click .add-part' : 'addPartPurchase'
    'click .add-service' : 'addService'

  initialize: ({@modification, @currentPurchasePictureId, @cps_tab, @typeItems})->
    @partPurchasesAttributes = new Models.PartPurchaseAttributes
    @serviceAttributes = new Models.ServiceAttributes
    @item_position = 0

  buildItemView: (item, ItemView)->
    if item instanceof Models.PartPurchase
      @item_position = @item_position + 1
      new Pages.Vehicles.Modifications.ModificationPart model: item, purchaseAttributes: @partPurchasesAttributes, currentPurchasePictureId: @currentPurchasePictureId, cps_tab: @cps_tab, itemPosition: @item_position, user: @modification.get('user')
    else if item instanceof Models.Service
      new Pages.Vehicles.Modifications.ModificationService model: item, purchaseAttributes: @serviceAttributes, currentPurchasePictureId: @currentPurchasePictureId, cps_tab: @cps_tab
    else
      throw 'unrecognized model'

  appendHtml: (collectionView, itemView)->
    collectionView.$('.purchases-container').append itemView.el

  addPartPurchase: ->
    MyApp.vent.trigger 'modification:mode_edit:active'
    @partPurchasesAttributes.fetch
      success: =>
        partPurchase = new Models.PartPurchase
        partPurchase.set modification: @modification, manufacturer: new Models.Vendor, supplier: new Models.Vendor, vendor: new Models.Vendor, pictures: []
        @collection.add  partPurchase
    false

  addService: ->
    MyApp.vent.trigger 'modification:mode_edit:active'
    @serviceAttributes.fetch
      success: =>
        service = new Models.Service
        service.set modification: @modification, provider: new Models.Vendor, pictures: []
        @collection.add service
    false

  serializeData: ->
    showControls: Models.Ability.canManageModification(@modification)
    typeItems: @typeItems