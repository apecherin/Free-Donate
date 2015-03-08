#= require backbone_app/views/mixins/sortable
#= require ./pictures_item
class Fragments.Galleries.Pictures extends Fragments.Pictures
  itemView: Fragments.Galleries.PicturesItem
  initializeSortable: Views.Mixins.initializeSortable

  initialize: ->
    super
    @bindTo @, 'render', @initializeSortable if @canManage