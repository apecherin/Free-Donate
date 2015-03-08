#= require ./cutouts_item

class Fragments.Collages.Cutouts extends Backbone.Marionette.CollectionView
  tagName  : 'ul'
  itemView : Fragments.Collages.CutoutsItem


  initialize: (attributes)->
    @itemViewOptions = =>
      modeEdit: attributes.modeEdit
      modeOnlyList:  attributes.modeOnlyList? and attributes.modeOnlyList == true