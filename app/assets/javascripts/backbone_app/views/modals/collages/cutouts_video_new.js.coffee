class Modals.Collages.CutoutsVideoNew extends Backbone.Marionette.ItemView
  template: 'modals/collages/cutouts_video_new'

  events:
    'keyup #youtube-link' : 'updatePreview'
    'click .embed-video'  : 'updateCutoutVideo'


  initialize: ->
    @cutoutAttrs = {}
    @isValid = false


  serializeData: ->
    youTubeSrc:  Models.Cutout.youTubeSource(@cutoutAttrs)
    youTubeLink: @youTubeLink
    isValid:     @isValid


  onRender: ->
    @$('.embed-video').attr('disabled', true) unless @isValid
    @$('#youtube-link').focus()
    @$('#youtube-link').val(@youTubeLink)


  updatePreview: (event)->
    @youTubeLink = event.target.value
    @cutoutAttrs =
      youtube_video_id: Models.Cutout.youTubeVideoId(event.target.value)
      youtube_start_at: Models.Cutout.youTubeStartAt(event.target.value)
      youtube_hd      : Models.Cutout.youTubeHd(event.target.value)
    wasValid = @isValid
    @isValid = if @cutoutAttrs.youtube_video_id then true else false
    @render() unless @isValid == wasValid


  updateCutoutVideo: ->
    @model.set @cutoutAttrs
    @model.save({})
    @close()
    false
