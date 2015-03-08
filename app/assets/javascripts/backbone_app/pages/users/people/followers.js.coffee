class Fragments.Users.People.Followers extends Backbone.Marionette.CompositeView
  template: 'fragments/users/people/followers'
  itemView: Fragments.Users.People.UserItem

  initialize: ({@user})->

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.followers-list').append(itemView.el)