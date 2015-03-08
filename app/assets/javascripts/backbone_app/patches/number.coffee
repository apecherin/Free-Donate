Number::toFloatTry = (count = 2) ->
  if @ % 1 is 0
    @
  else
    parseFloat(@.toFixed(count))

Number::padDigits = (digits) ->
  Array(Math.max(digits - String(@).length + 1, 0)).join(0) + @