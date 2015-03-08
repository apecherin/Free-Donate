#=require ./index_item

class Fragments.Breadcrumb.Index extends Backbone.Marionette.CollectionView
  itemView  : Fragments.Breadcrumb.IndexItem
  tagName   : 'ul'

  initialize: ()->
    @bindTo(MyApp.vent, 'change_widht_of_screen', @ellipsysBreadcrumb)

  onRender: ->
    setTimeout =>
      @ellipsysBreadcrumb()
    , 200

  ellipsysBreadcrumb: () ->
    if $('#breadcrumb ul').height() > 20
      $('#breadcrumb li:not(.ellipsys)').each (i, li) ->
        $(li).remove()
        if $('#breadcrumb ul li.ellipsys').length is 0
          $('#breadcrumb ul li:first').prepend('<li class="ellipsys"><a href="#">(...)</a><span class="divider">|</span></li>')
        return false if $('#breadcrumb ul').height() < 40