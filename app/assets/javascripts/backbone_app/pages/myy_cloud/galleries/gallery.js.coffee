class Pages.MyyCloud.Gallery extends Pages.Galleries.Show

  setBreadcrumbs: ->
    #TO DO get user from parent
    @user = @gallery.get('user')
    tab = if @gallery.get('privacy') is 'private' then 'priv' else 'pub'
    @breadcrumbs = Collections.Breadcrumbs.forImportedGallery(tab, @gallery, @user)


  canManage: ->
    Models.Ability.canManageAlbum(@gallery)

  collagesEnabled: ->
    false

  myyCloud: ->
    true
