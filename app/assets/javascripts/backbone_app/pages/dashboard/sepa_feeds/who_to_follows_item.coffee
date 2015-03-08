class Pages.Dashboard.WhoToFollowsItem extends Backbone.Marionette.ItemView
  template: 'pages/dashboard/sepa_news_feeds/who_to_follows_item'
  className: 'to-follow-item'
  events:
    'click .follow' : 'followToUser'

  initialize: ({ })->
    @side_view_1_url = @model.get('side_views').side_view_1
    @side_view_2_url = @model.get('side_views').side_view_2

  followToUser: ->
    if Store.get('currentUser')
      following = new Models.Following
      following.collection = new Collections.Followings
      following.set thing_id: @model.id, thing_type: 'User',
      following.save null,
        success: =>
          Backbone.history.navigate(Routers.Main.showUserProfilePath(@model.id), true)
    else
      Backbone.history.navigate(Routers.Main.registrationPath(), true)
    false

  serializeData: ->
    brandNames: @model.get('brands_names')
    carsCount: @model.get('cars_count')
    motosCount: @model.get('moto_count')
    trucksCount: @model.get('trucks_count')
    sideView1Url: @side_view_1_url
    sideView2Url: @side_view_2_url
    user: @model.get('user')