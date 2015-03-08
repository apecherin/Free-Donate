class Lib.EasyForm.Components.Tag
  @make: (tagName, attributes, text...) ->
    t = new Tag
    t.name = tagName
    t.attributes = attributes
    t.text = ''
    t.text = text.join('')
    t

  openTag: ->
    attributeStrings = []
    close = null
    unless @text
      close = ' />'
    else
      close = '>'

    attributeStrings.push("#{key}=\"#{attribute}\"") for key, attribute of @attributes when key != 'text'
    attributeString = if attributeStrings.length > 0 then ' ' + attributeStrings.join(' ') else ''

    "<#{@name}#{attributeString}#{close}"

  closeTag: (name) ->
    "</#{@name}>"

  tag: ->
    parts = [@openTag()]
    parts.push @text
    parts.push @closeTag() if @text.length > 0
    parts.join('')

  toString: ->
    @tag()