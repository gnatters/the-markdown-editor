'use strict';


angular.module('mdApp')


.filter 'md2html', () ->
  # Turns markdown into html courtesy of markdown.js
  (md) ->  if md and md.length then markdown.toHTML(md) else ''


.filter 'scopeCSS', () ->
  # Parses the supplied CSS and restricts it to the scope of the supplied prefix
  # - selectors referencing blacklisted tags are removed
  # - references to body are replaced with the prefix
  # - all other selectors are prefixed so as to limit their scope appropriately
  (css, prefix) ->
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

