# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  # Show the form to gather data at page load.
  $('#gather-data').modal({})


  # Setup file uploader.
  $('form.uploader').each (index, element)->
    $uploader = $(element)
    url      = $uploader.attr('action')
    formData = { token: $uploader.find('input.gallery-token').val() }

    $uploader.fileupload
      url:       url
      formData:  formData
      paramName: 'picture[image]'
      forceIframeTransport: false

      uploadTemplate: (object)->
        JST['uploader/upload'](object: object)

      downloadTemplate: (object)->
        JST['uploader/download'](object: object)


    $uploader.bind
      fileuploadadd: (event, data)->


      # When a upload finishes.
      fileuploaddone: (event, data)->
        result = data.files[0]

      # When all uploads are finished.
      fileuploadstop: (event, data)->
        $submit = $uploader.find('input[type=submit]')
        $submit.prop('disabled', false)
