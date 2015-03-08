Views.FavoriteListItem = Backbone.Marionette.ItemView.extend
  template: 'favorites/favorite_list_item'
  tagName:  'tr'

  events:
    'click .delete' : 'delete'


  delete: ->
    id      = @model.get('id')
    confirm = window.confirm('Really remove this favorite?')
    xhr     = confirm && $.post("/favorites/#{id}", _method: 'DELETE')

    xhr.done (data)=> @remove()
    false
