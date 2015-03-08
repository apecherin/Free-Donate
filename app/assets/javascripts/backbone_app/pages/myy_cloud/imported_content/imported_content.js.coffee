class Pages.MyyCloud.ImportedContent extends Backbone.Marionette.Layout
  id        : 'imported-content'
  template  : 'pages/myy_cloud/imported_content'

  regions:
    picturesRegion: '.profile-pictures-container'

  events:
   'click .pick-on'  : 'pickOn'
   'click .pick-off' : 'pickOff'
   'click .transfert' : 'transfert'
   'click .delete'    : 'delete'

  initialize: ({@pictures, @albums})->
    @picking = false
    @pickedStore = new Backbone.Collection
    @bindTo MyApp.vent, 'imported_picture:picked', (picture)=>
      @pickedStore.add picture
      if @pickedStore.length is 1
        @changeStateOfButtons(false)

    @bindTo MyApp.vent, 'imported_picture:unpicked', (picture)=>
      @pickedStore.remove picture
      if @pickedStore.length is 0
        @changeStateOfButtons(true)


  pickOn: ->
    @picking = true
    @render()

  pickOff: ->
    @picking = false
    @render()

  changeStateOfButtons: (state)->
    @buttons().attr 'disabled', state

  buttons: ->
    @$('.transfert, .delete')

  transfert: ->
    if @pickedStore.length > 0
      MyApp.modal.show new Pages.MyyCloud.ImportedContent.Transfert
        collection: @pickedStore
        albums: @albums

    false

  delete: ->
    bootbox.confirm 'Are you sure?', (submit)=>
      if submit
        activeRequests = @pickedStore.length
        while picture = @pickedStore.pop()
          picture.destroy
            silent: true
            wait: true
            success: =>
              activeRequests -= 1
              MyApp.vent.trigger 'pictures:deleted' if activeRequests is 0

    false

  onRender: ->
    comparator = (item)=> -item.get('id')
    @pictures.comparator = comparator
    @picturesRegion.show new Pages.MyyCloud.ImportedContent.Pictures
      collection: @pictures.sort()
      canManage: false
      picking: @picking

  serializeData: ->
    picking: @picking