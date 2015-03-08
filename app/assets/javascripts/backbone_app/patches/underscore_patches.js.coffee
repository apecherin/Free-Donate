_.extend _,
  dasherize: (str) ->
    str.replace /_/g, '-'

  classify: (str) ->
    @dasherize(str.replace /\s/g, '-').toLowerCase()
