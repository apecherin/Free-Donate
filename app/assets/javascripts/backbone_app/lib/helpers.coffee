class Lib.Helpers
  @merge = (options, overrides) ->
#    extend (extend {}, options), overrides

    $.extend {}, options, overrides

  @reject = (obj, predicate) ->
    res = {}
    res[k] = v for k, v of obj when not predicate k, v
    res