
hogan = require 'hogan.js'
layout = require 'express-layout'
view = layout.view
utils = require 'livelyutils'
async = require 'async'

renderFun= (template, data, cb) ->
  cb null, (hogan.compile template).render data

chain = (middlewares...) -> (req, res, next) ->
  forEach = (each, cb) -> each req, res, cb
  async.forEachSeries middlewares, forEach, next

templates = {}
templates.base = """
<!DOCTYPE html>
<html>
  <head>
    {{{head}}}
  </head>
  <body>
    {{{body}}}
  </body>
</html>
"""

templates.head = """
<title>{{title}}</title>
{{#js}}
<script type="text/javascript" src="{{.}}"></script>
{{/js}}
{{#css}}
<link rel="stylesheet" href="{{.}}">
{{/css}}
"""

views = {}
views.base = () ->
  view
    template: templates.base
    renderFun: renderFun
    requires: ["head", "body"]

views.head = () ->
  headerData = js: [], css: [], title: "Default"
  view
    template: templates.head
    renderFun: renderFun
    data: headerData
    addJs: (js) -> headerData.js = headerData.js.concat js
    addCSS: (css) -> headerData.css = headerData.css.concat css
    title: (title) -> if title then headerData.title = title else headerData.title
    addTitle: (title) -> headerData.title = headerData.title + title

components = {}
components.base = (req, res, next) ->
  base = views.base()
  head = views.head()
  base.subview 'head', head
  res.rootView base
  res.view 'head', head
  next()

module.exports =
  components: components
  views: views
