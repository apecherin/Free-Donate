#= require backbone_app/pages/galleries/show

class Pages.Albums.UserGallery extends Pages.Galleries.Show

  setBreadcrumbs: ->
    @breadcrumbs = Collections.Breadcrumbs.forUserAlbum(@gallery)

  canManage: ->
    Models.Ability.canManageAlbum(@gallery)

  collagesEnabled: ->
    false