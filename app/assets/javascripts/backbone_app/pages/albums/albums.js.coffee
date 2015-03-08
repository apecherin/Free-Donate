#= require ./album_item

class Pages.Albums.Albums extends Backbone.Marionette.CollectionView
  itemView: Pages.Albums.AlbumItem
  tagName: 'ul'
  className: 'thumbnails'