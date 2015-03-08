# From Derick Bailey.
# http://lostechies.com/derickbailey/2012/04/17/managing-a-modal-dialog-with-backbone-and-marionette/
class Views.ModalRegion extends Backbone.Marionette.Region
  el: '#modal'

  constructor: ->
    _.bindAll(this)
    Backbone.Marionette.Region::constructor.apply(this, arguments)
    @on('view:show', @showModal, this)


  getEl: (selector)->
    $el = $(selector)

    $el.on('hidden', @close)
    $el


  showModal: (view)->
    view.on('close', @hideModal, this)

    keyboard = if view.modalKeyboard? then view.modalKeyboard else true
    @$el.modal(show: false)
    @$el.data().modal.options.keyboard = keyboard

    @$el.modal('show')


  hideModal: ->
    @$el.modal 'hide'
