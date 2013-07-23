The Markdown Editor
===================

[Demo](http://gnatters.github.io/the-markdown-editor/)

Mostly a wee project for me to build confidence with [angular.js](http://angularjs.org/)

Uses a slightly modified version of markdown.js.
Uses a cors proxy to load in arbitrary external style sheets.

Includes fitlers for:

* parsing markdown into html
* pretty printing CSS and HTML
* rescoping arbitrary StyleSheets to only apply within a given element on the page.


Usage
---

Requires Node.js, Grunt & Bower. e.g.

    npm install -g bower grunt

To build locally cd into the local directory and run:

    npm install
    bower install
    grunt server

----

[MIT License](http://opensource.org/licenses/MIT) etc.