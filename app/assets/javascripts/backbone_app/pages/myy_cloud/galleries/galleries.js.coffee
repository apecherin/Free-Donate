#= require ./gallery_item

class Pages.MyyCloud.Galleries extends Backbone.Marionette.CompositeView
  template: 'pages/myy_cloud/galleries/galleries'
  itemView: Pages.MyyCloud.GalleryItem

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.thumbnails').prepend(itemView.el)
