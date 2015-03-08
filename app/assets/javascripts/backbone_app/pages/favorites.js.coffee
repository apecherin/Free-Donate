Pages.Favorites = Backbone.Marionette.CompositeView.extend
  template: 'pages/favorites'
  itemView: Views.FavoriteListItem


  initialize: (attributes)->
    @userId      = attributes.userId
    @collection ?= new Backbone.Collection([])

    $.getJSON('/my/favorites.json')
      .done (data)=>
        @collection.reset(data)


  appendHtml: (collectionView, itemView)->
    $list = collectionView.$('table.favorites tbody')
    $list.append(itemView.el)
