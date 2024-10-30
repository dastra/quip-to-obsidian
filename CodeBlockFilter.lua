local fenced = '```\n%s\n```\n'
function CodeBlock (cb)
  -- use pandoc's default behavior if the block has classes or attribs
  if cb.classes[1] or cb.attributes[1] then
    return nil
  end
  return pandoc.RawBlock('markdown', fenced:format(cb.text))
end