#= require ./modal_region
class Views.InnerModalRegion extends Views.ModalRegion
  el: '#inner-modal'


  showModal: (view)->
    view.on('close', @hideInnerModal, this)
    @$el.modal({
      show: true,
      backdrop: false
    })


  hideInnerModal: ->
    @hideModal()
    $('body').addClass('modal-open')
