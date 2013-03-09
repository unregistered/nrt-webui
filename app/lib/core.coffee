require('jquery')
require('handlebars')
require('ember')
require('ember-data')
require('nrt-webui/ext')
require('nrt-webui/env')

require 'bootstrap'
require 'when' # Deferreds for autobahn
require 'autobahn'
require 'raphael'
require 'raphael-zpd' # Zoom
require 'jquery-ui'

Raphael.fn.connection = (obj1, obj2, line, bg) ->
  if obj1.line and obj1.from and obj1.to
    line = obj1
    obj1 = line.from
    obj2 = line.to
  bb1 = obj1.getBBox()
  bb2 = obj2.getBBox()
  p = [
    x: bb1.x + bb1.width / 2
    y: bb1.y - 1
  ,
    x: bb1.x + bb1.width / 2
    y: bb1.y + bb1.height + 1
  ,
    x: bb1.x - 1
    y: bb1.y + bb1.height / 2
  ,
    x: bb1.x + bb1.width + 1
    y: bb1.y + bb1.height / 2
  ,
    x: bb2.x + bb2.width / 2
    y: bb2.y - 1
  ,
    x: bb2.x + bb2.width / 2
    y: bb2.y + bb2.height + 1
  ,
    x: bb2.x - 1
    y: bb2.y + bb2.height / 2
  ,
    x: bb2.x + bb2.width + 1
    y: bb2.y + bb2.height / 2
  ]
  d = {}
  dis = []
  i = 0

  while i < 4
    j = 4

    while j < 8
      dx = Math.abs(p[i].x - p[j].x)
      dy = Math.abs(p[i].y - p[j].y)
      if (i is j - 4) or (((i isnt 3 and j isnt 6) or p[i].x < p[j].x) and ((i isnt 2 and j isnt 7) or p[i].x > p[j].x) and ((i isnt 0 and j isnt 5) or p[i].y > p[j].y) and ((i isnt 1 and j isnt 4) or p[i].y < p[j].y))
        dis.push dx + dy
        d[dis[dis.length - 1]] = [i, j]
      j++
    i++
  if dis.length is 0
    res = [0, 4]
  else
    res = d[Math.min.apply(Math, dis)]
  x1 = p[res[0]].x
  y1 = p[res[0]].y
  x4 = p[res[1]].x
  y4 = p[res[1]].y
  dx = Math.max(Math.abs(x1 - x4) / 2, 10)
  dy = Math.max(Math.abs(y1 - y4) / 2, 10)
  x2 = [x1, x1, x1 - dx, x1 + dx][res[0]].toFixed(3)
  y2 = [y1 - dy, y1 + dy, y1, y1][res[0]].toFixed(3)
  x3 = [0, 0, 0, 0, x4, x4, x4 - dx, x4 + dx][res[1]].toFixed(3)
  y3 = [0, 0, 0, 0, y1 + dy, y1 - dy, y4, y4][res[1]].toFixed(3)
  path = ["M", x1.toFixed(3), y1.toFixed(3), "C", x2, y2, x3, y3, x4.toFixed(3), y4.toFixed(3)].join(",")
  if line and line.line
    line.bg and line.bg.attr(path: path)
    line.line.attr path: path
  else
    color = (if typeof line is "string" then line else "#000")
    bg: bg and bg.split and @path(path).attr(
      stroke: bg.split("|")[0]
      fill: "none"
      "stroke-width": bg.split("|")[1] or 3
    )
    line: @path(path).attr(
      stroke: color
      fill: "none"
    )
    from: obj1
    to: obj2

window.App = Ember.Application.create(
  VERSION: '0.1'
  ready: ->
    App.router.serversController.pushObjects [
        # App.Server.create(
        #     name: 'localhost'
        #     host: 'localhost'
        #     port: 9000
        # ),
        App.Server.create(
            name: 'UbuntuVM'
            host: 'ubuntu1204.local'
            port: 8080
        ),
        App.Server.create(
            name: 'iLab'
            host: '55.221.13.240'
            port: 9000
        )
    ]
)
