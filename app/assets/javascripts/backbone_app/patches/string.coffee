String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1)

String::underscore = ->
  @split('-').join '_'

String::last = ->
  @charAt(@length - 1)

String::treetopCamelize = ->
  @split('_').map((el)-> el.capitalize()).join('')

String::titlelize = ->
  @split(' ').map((el)-> el.capitalize()).join(' ')

String::humanize = ->
  @split('_').map((el)-> el.capitalize()).join(' ')

String::pluralize = (count, plural) ->
  plural = @ + "s" unless plural?
  plural = plural.substr(0, plural.length - 2) + "ies" if @.substr(-1) in ['y']
  (if count is 1 then @ else plural)

String::toFloatTry = ->
  @


