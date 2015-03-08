class Fragments.Users.People.Followings extends Backbone.Marionette.CompositeView
  template: 'fragments/users/people/followings'
  itemView: Fragments.Users.People.UserItem

  initialize: ({@user})->

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.followings-list').append(itemView.el)