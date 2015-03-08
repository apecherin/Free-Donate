#=require ./identification
class Fragments.Vehicles.Identification.Picture extends Backbone.Marionette.Layout
  template: 'fragments/vehicles/picture'
  regions:
    galleryLayout: '#gallery-layout'

  events:
    'click .change' : 'changePictureClicked'
    'click .cutout' : 'handleCutout'

  onRender: ->
    callback = =>
      @initializeFileUpload()
    setTimeout callback, 0

  serializeData: ->
    vehicle:      @model
    showPicture:  Models.Ability.canShowVehiclePicture @model
    showControls: Models.Ability.canManageVehicle @model

  changePictureClicked: ->
    @$('.progress-success').show()
    @$('input[type=file]').click()
    @$("img.image_progress").show()
    false

  handleCutout: ->
    @handleCutoutPicture()

  handleCutoutPicture: ->
    if Models.Ability.canManageVehicle @model
      MyApp.modal.show new Pages.Pictures.VehicleImage
        model  : @model
    else
      Backbone.history.navigate(Routers.Main.showVehiclePath(@model.id), true)
    false

  cleanProgress: ->
    @$('.bar').css('width', '0%')
    @$('.progress-success').hide()


  initializeFileUpload: ()->
    $fileInputs = @$('input[type=file]')
    if $fileInputs.length is 0 || $fileInputs.data().fileupload? then return

    $f = $fileInputs.fileupload()

    $f.on 'fileuploadprogress', (event, data)=>
      @$('.bar').css('width',parseInt(data.loaded / data.total * 100, 10) + '%')

    $f.on 'fileuploaddone', (event, data)=>
      new_url = data.result.avatars.normal.url
      img = @$(event.target).closest('#picture').find('img')
      img.attr('src', new_url)
      @cleanProgress()
      @model.setAvatarsUrl(data.result.avatars.normal.url, data.result.avatars.cutout.url)
      unless data.result.properties_exist
        MyApp.vent.trigger 'notify:success', I18n.t('change_vehicle_picture.success', scope: 'tabs.identification_content')
        Backbone.history.navigate Routers.Main.showSpecificationsTabPath(@model), true

    $f.on 'fileuploadstop', (event, data)=>
      @cleanProgress()