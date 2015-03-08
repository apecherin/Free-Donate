#= require ./comparison_tables_row

class Fragments.Users.ComparisonTablesRows extends Backbone.Marionette.CompositeView
  template: 'pages/users/comparison_tables_rows'
  itemView: Fragments.Users.ComparisonTablesRow

  appendHtml: (collectionView, itemView) ->
    collectionView.$el.append(itemView.el)
