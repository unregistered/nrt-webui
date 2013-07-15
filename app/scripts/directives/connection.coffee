angular.module("nrtWebuiApp").directive 'connection', (ConnectorService, SelectionService, ConfigService, ModuleParserService) ->
    require: '^raphael'
    restrict: "E"
    template: """
    <div></div>
    """
    replace: true

    scope: {
        connection: "=model"
    }

    link: (scope, iElement, iAttrs, controller) ->
        scope.getFromBBox = ->
            ConnectorService.getPortBBox scope.connection.bbuid1, scope.connection.module1, scope.connection.portname1

        scope.getToBBox = ->
            ConnectorService.getPortBBox scope.connection.bbuid2, scope.connection.module2, scope.connection.portname2

        scope.getCurvedPathString = ->
            bb1 = scope.getFromBBox()
            bb2 = scope.getToBBox()

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

        ###
        Returns the path string, which can be curved, straight, or none, based on performance. Optionally memoize the path string for performance.
        ###
        scope.getPathString = ->
            return scope.getCurvedPathString()

        scope.drawLine = ->
            l = controller.paper.path(scope.getPathString())
            l.attr(
                stroke: ConfigService.UI_CONNECTION_INACTIVE_COLOR
                'stroke-width': 1
                fill: "none"
            )

            # if @get('phantom')
            #     l.attr('stroke-dasharray': '--')

            return l

        scope.drawHitbox = ->
            b = controller.paper.path(scope.getPathString())
            b.attr(
                stroke: ConfigService.UI_CONNECTION_ACTIVE_COLOR
                'stroke-width': 10
                'stroke-opacity': 0.1
            )
            return b


        scope.$watch("connection", ->
            scope.raphael_drawings = {}
            scope.raphael_drawings.line = scope.drawLine()
            scope.raphael_drawings.hitbox = scope.drawHitbox()

            scope.raphael_drawings.hitbox.mousedown =>
                SelectionService.set 'connection', scope.connection
                scope.$apply()

        )

        scope.$watch("connection._selected", ->
            w = if scope.connection._selected then 3 else 1
            scope.raphael_drawings.line.attr(
                'stroke-width': w
            )
        )

        # Observe module coordinates
        scope.from_module = ModuleParserService.modules[scope.connection.module1]
        scope.to_module = ModuleParserService.modules[scope.connection.module2]
        scope.$watch("[from_module.x, from_module.y, to_module.x, to_module.y]", ->
            scope.raphael_drawings.line.attr(path: scope.getPathString())
            scope.raphael_drawings.hitbox.attr(path: scope.getPathString())
        , true)

        # Observe module selection
        scope.$watch("[from_module._selected, to_module._selected]", ->
            color = ConfigService.UI_CONNECTION_ACTIVE_COLOR
            if scope.from_module._selected || scope.to_module._selected
                color = ConfigService.UI_CONNECTION_ACTIVE_COLOR
            else
                if SelectionService.get('module').length
                    # There's a selected module
                    color = ConfigService.UI_CONNECTION_INACTIVE_COLOR
                else
                    color = ConfigService.UI_CONNECTION_ACTIVE_COLOR

            scope.raphael_drawings.line.attr
                stroke: color
        , true)
