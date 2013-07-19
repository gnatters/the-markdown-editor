'use strict';


angular.module('mdApp')


.filter 'md2html', () ->
  # Turns markdown into html courtesy of markdown.js
  (md) ->  if md and md.length then markdown.toHTML(md) else ''


.filter 'scopeCSS', ($filter) ->
  # Parses the supplied CSS and restricts it to the scope of the supplied prefix
  # - selectors referencing blacklisted tags are removed
  # - references to body are replaced with the prefix
  # - all other selectors are prefixed so as to limit their scope appropriately
  (css, prefix, prettify) ->
    doc = document.implementation.createHTMLDocument("")
    styles = document.createElement("style")
    styles.innerText = css
    doc.body.appendChild(styles)
    blacklist = /(^| )(head|title|link|style|script)($| )/
    response = ''
    scope_selectors = (rules) ->
      return unless rules.length
      for i in [0...rules.length]
        if rules[i].selectorText
          selectors = rules[i].selectorText.split(', ')
          selector = ((if /(^| )(body|html)($| )/.test(s) then s.replace(/(body|html)/, prefix) else "#{prefix} #{s}") for s in selectors when not blacklist.test(s)).join(', ')
          if selector
            rules[i].selectorText = selector
            response += rules[i].cssText + ' '
        else if rules[i].media[0] is 'screen'
          scope_selectors(rules[i].cssRules)
    scope_selectors(styles.sheet.cssRules)
    response


.filter 'prettifyCSS', () ->
  (css) ->
    `css
    .replace( / { /g , ' {\n  ' )
    .replace( /; } /g, ';\n}\n' )
    .replace( / } /g,  '\n}\n'  )
    .replace( /}/g,    '}\n'    )
    .replace( /; /g,   ';\n  '  )`


.filter 'prettifyHTML', () ->
  # a simple as possible method for adding sensible whitespace to blocky html
  # makes no attempt to fail gracefully given malformed html (e.g. unclosed tags without excuse)
  indent = (n,inline_count)  -> if n <= 0 then "" else Array(n-inline_count+1).join('  ')
  inline = (tag) -> tag in ['span', 'a', 'code', 'i', 'b', 'em', 'strong', 'abbr', 'img', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'bdi', 'bdo', 'wbr', 'kbd', 'del', 'ins', 's', 'rt', 'rp', 'var', 'time', 'sub', 'sup', 'link', 'title', 'label', 'input']
  closing = (tag) -> tag in ['area', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'base', 'param', 'source', 'track', 'wbr'] # option can be self closing but usually isn't!
  count_inline = (stack) -> (t for t in stack when inline(t)).length
  tag_re = '<(?:(?:(\\w+)[^><]*?)|(?:\\/(\\w+)))>'
  tag_re = new RegExp(tag_re)
  tag_re.compile(tag_re)

  (html) ->
    saved = html
    inline_count = 0
    stack = []
    pretty_html = ""

    while html
      i = html.search(tag_re)
      unless i+1 # no tags left
        pretty_html += html
        html = ""
      m = html.match(tag_re)
      if tag_name = m[1] # found opening tag
        if inline tag_name # open inline tag
          pretty_html += indent(stack.length, inline_count) if pretty_html.charAt(pretty_html.length-1) is '\n'
          pretty_html += html.substr(0,i+m[0].length)
          stack.push tag_name
          inline_count += 1
          html = html.substr(i+m[0].length)
        else # open block tag
          pretty_html += indent(stack.length, inline_count) if i and pretty_html.charAt(pretty_html.length-1) is '\n'
          pretty_html += "#{html.substr(0,i)}"
          pretty_html += '\n' unless pretty_html.charAt(pretty_html.length-1) is '\n'
          pretty_html += indent(stack.length, inline_count) + m[0]
          stack.push tag_name
          pretty_html += '\n'
          html = html.substr(i+m[0].length)
      else if tag_name = m[2] # found closing tag
        last_t = stack.lastIndexOf(tag_name)
        if last_t+1
          if inline tag_name # close inline tag
            inline_count -= 1
            stack.splice(last_t)
            pretty_html += "#{html.substr(0,i)}#{m[0]}"
            html = html.substr(i+m[0].length)
          else # close block tag
            pretty_html += indent(stack.length, inline_count) if i and pretty_html.charAt(pretty_html.length-1) is '\n'
            stack.splice(last_t)
            pretty_html += "#{html.substr(0,i)}#{ if pretty_html.charAt(pretty_html.length-1) is '\n' then '' else '\n'}#{indent(stack.length, inline_count)}#{m[0]}"
            html = html.substr(i+m[0].length)
            pretty_html += '\n' unless html[0] is '\n'
        else
          pretty_html += "#{html.substr(0,i+m[0].length)}"
          html = html.substr(i+m[0].length)

      else # um wut?
        console.warn "UH OH: found a tag that's not an opening tag or a closing tag!?!?"
    pretty_html



