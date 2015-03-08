class Fragments.Vehicles.SilhouetteCustomBuilder extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/silhouette/custom_builder'

  events:
    'click #sideview_upload' : 'changePictureClicked'
    'click #sideview_cancel' : 'destroySideView'

  onRender: ->
    @initializeFileUpload()

  initializeFileUpload: ->
    $f = @$('input[type=file]').fileupload
      formData:
        vehicle_id: @vehicle.get('id')

    $f.on 'fileuploaddone', (event, data)=>
      @model.set data.result
      @render()

  initialize: ({@model, @vehicle})->

  changePictureClicked: ->
    @$('input[type=file]').click()
    false

  destroySideView: =>
    @model.destroy
      data: JSON.stringify({vehicle_id: @model.get('vehicle').id || @model.get('vehicle_id')})
      contentType: 'application/json'
      success: =>
        @model = new Models.SideView
        @vehicle.set 'side_view', null
        @render()

  serializeData: ->
    side_view:  @model