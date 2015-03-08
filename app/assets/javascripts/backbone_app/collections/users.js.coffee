#=require ./on_reset
class Collections.ActiveUsers extends Collections.OnReset
  model: Models.User
  url: '/api/active_users'
