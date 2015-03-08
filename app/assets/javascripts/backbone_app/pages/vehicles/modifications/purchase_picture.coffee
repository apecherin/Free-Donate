class Pages.Vehicles.Modifications.PurchasePicture extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/modifications/purchase_picture'
  className: 'purchase-picture inline-block'

  events:
    'click .delete' : 'deletePicture'

  initialize: ({@showControls, @currentPurchasePictureId, @pictures, @modification})->
    @currentPurchasePictureId = if @currentPurchasePictureId? then @currentPurchasePictureId else null

  onRender: ->
    @$el.addClass HAML.globals()['domId'](@model)
    @currentPurchasePictureId = null

  deletePicture: ->
    @model.destroy
      wait: true
      success: =>
        MyApp.vent.trigger 'part_purchase_picture:removed'
        MyApp.vent.trigger 'notify:success', I18n.t('destroyed', scope: "notification.#{@model.constructorName}")
      error: =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: "notification.#{@model.constructorName}")
    false

  serializeData: ->
    picture:      @model
    showControls: if typeof @showControls isnt 'undefined' then @showControls else Models.Ability.canManagePicture(@model)