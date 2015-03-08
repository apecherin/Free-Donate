class Pages.Vehicles.Expenses.DrivingInfo extends Backbone.Marionette.Layout
  template: 'pages/vehicles/expenses/tab_info/driving_info'

  events:
    'change .add-track-operation' : 'addOperation'

  regions:
    'trackOperations' : '#track-operations'

  initialize: ({@vehicle, @vehicle_tracks, @track_operations})->
    @currentUser = Store.get('currentUser')
    @user = @vehicle.get('user')
    @canEdit = @currentUser && @user.id is @currentUser.id
    @bindTo MyApp.vent, 'track_operations:item_removed', @updateTrackOperationList
    @bindTo MyApp.vent, 'track_operations:update_items', @updateTrackOperationList

  onRender: ->
    @trackOperations.show new Fragments.Expenses.TrackOperations
      collection: @vehicle_tracks
      canEdit: @canEdit
      vehicle: @vehicle

  updateTrackOperationList: ->
    @vehicle_tracks.fetch wait: true, data: {track_operations: @track_operations}, success: (maintenance_operations)=>
      @render()

  addOperation: (event) ->
    if event.currentTarget.value isnt '[+] Add More'
      new_model = new Models.VehicleTrack(type: event.currentTarget.value, vehicle: @vehicle)
      @vehicle_tracks.add new_model
    false

  serializeData: ->
    track_operations: @track_operations
    canEdit: @canEdit