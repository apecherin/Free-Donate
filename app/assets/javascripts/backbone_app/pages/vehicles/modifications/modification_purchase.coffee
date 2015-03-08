#= require ./purchase_pictures

class Pages.Vehicles.Modifications.ModificationPurchase extends Backbone.Marionette.Layout
  className: 'purchase-container'

  regions:
    picturesContainer: '.purchase-pictures-container'

  cancelEditing: Pages.Mixins.cancelEditing
  deletePurchase: Pages.Mixins.destroyModel
  enableSaveButton: Pages.Mixins.enableSaveButton
  savePurchase: Pages.Mixins.saveModel
  isEditMode: Pages.Mixins.isEditMode

  switchToEditMode: ->
    @purchaseAttributes.fetch success: =>  Pages.Mixins.switchToEditMode.call(@)
    false

  clickFileInput: ->
    @$('.pictures-input').click()
    false

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)

    if !@isEditMode()
      @initializeFileUpload()

  initializeFileUpload: ->
    $f = @$('.pictures-input').fileupload
      url: @model.get('pictures').url()
      type: 'POST'

    $f.on 'fileuploadstart', (event, data)=>
      $fileInputs = @$('input[type=file]')
      pictures = @model.get('pictures')
      picture = new pictures.model data['result']
      MyApp.vent.trigger 'notify:warning', I18n.t('wait_message', scope: "notification.#{picture.constructorName}")

    $f.on 'fileuploaddone', (event, data)=>
      pictures = @model.get('pictures')
      picture = new pictures.model data['result']
      if picture.isServerValid()
        pictures.add picture
        MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: "notification.#{picture.constructorName}")
      else
        MyApp.vent.trigger 'notify:error', I18n.t('saved', scope: "notification.#{picture.constructorName}")

    $f.on 'fileuploadstop', (event, data)=>
      MyApp.vent.trigger 'part_purchase_picture:removed'

  initialize: ({@model, @vehicle})->