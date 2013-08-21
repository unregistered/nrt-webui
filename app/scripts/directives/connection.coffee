###
Draws a raphael connection
@broadcasts Connection.last_connection_rendered signifies that all connections have rendered
###
angular.module("nrtWebuiApp").directive 'connection', ($rootScope, ConnectorService, SelectionService, ConfigService, ModuleManagerService, HoverService, UtilityService) ->
    require: '^raphael'
    restrict: "E"
    template: """
    <div></div>
    """
    replace: true

    scope: {
        connection: "=model"
        last: "=last"
    }

    link: (scope, iElement, iAttrs, controller) ->
        scope.getFromBBox = ->
            ConnectorService.getPortBBox scope.connection.from_port

        scope.getToBBox = ->
            ConnectorService.getPortBBox scope.connection.to_port

        scope.getColor = ->
            UtilityService.str2color scope.connection.from_port.msgtype

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
                stroke: scope.getColor()
                'stroke-width': 2
                fill: "none"
            )
            if iAttrs.phantom
                l.attr('stroke-dasharray': '--')

            return l

        scope.drawOutline = ->
            l = controller.paper.path(scope.getPathString())
            l.attr(
                stroke: ConfigService.UI_CONNECTION_ACTIVE_COLOR
                'stroke-width': 3
                fill: "none"
            )
            if iAttrs.phantom
                l.attr('stroke-dasharray': '--')

            return l

        scope.drawHitbox = ->
            b = controller.paper.path(scope.getPathString())
            b.attr(
                stroke: ConfigService.UI_CONNECTION_ACTIVE_COLOR
                'stroke-width': 10
                'stroke-opacity': 0
            )
            return b

        scope.$watch("connection", ->
            scope.raphael_drawings = {}
            scope.raphael_drawings.outline = scope.drawOutline()
            scope.raphael_drawings.line = scope.drawLine()
            scope.raphael_drawings.hitbox = scope.drawHitbox()

            scope.raphael_drawings.hitbox.mousedown =>
                SelectionService.set 'connection', scope.connection
                scope.$apply()

            scope.raphael_drawings.hitbox.mouseover =>
                HoverService.set 'connection', scope.connection
                scope.$apply()

            if scope.last
                $rootScope.$broadcast("Connection.last_connection_rendered")
        )

        scope.updateAppearance = ->
            if !ConnectorService.isPairing()
                scope.raphael_drawings.line.attr
                    opacity: 1

                if scope.connection._selected
                    scope.raphael_drawings.outline.attr
                        'stroke-width': 5
                else
                    scope.raphael_drawings.outline.attr
                        'stroke-width': 4

                if scope.connection._hovered
                    scope.raphael_drawings.outline.attr
                        opacity: 0.6
                else
                    scope.raphael_drawings.outline.attr
                        opacity: 1
            else
                if scope.connection._hovered
                    # We are the selected pair
                    scope.raphael_drawings.outline.attr
                        'stroke-width': 4
                        opacity: 0.6
                else
                    scope.raphael_drawings.outline.attr
                        'stroke-width': 4
                        opacity: 0.2
                    scope.raphael_drawings.line.attr
                        opacity: 0.1


        # When we are selected
        scope.$watch("connection._selected", ->
            scope.updateAppearance()
        )

        # When we are hovered
        scope.$watch("connection._hovered", ->
            scope.updateAppearance()
        )

        # Observe module coordinates
        scope.$watch("[connection.from_module.x, connection.from_module.y, connection.to_module.x, connection.to_module.y]", ->
            scope.raphael_drawings.line.attr(path: scope.getPathString())
            scope.raphael_drawings.outline.attr(path: scope.getPathString())
            scope.raphael_drawings.hitbox.attr(path: scope.getPathString())
        , true)

        # Observe module selection
        scope.$on("SelectionService.selection_changed", ->
            scope.updateAppearance()
        )

        # Observe module hover
        scope.$on("HoverService.hover_changed", ->
            hovered_module = HoverService.getHovered 'module'
            return unless hovered_module
        )

        # Observe pairing state
        scope.$on("ConnectorService.pairing_state_changed", ->
            scope.updateAppearance()
        )

        # When we're being removed
        iElement.bind('$destroy', ->
            _.each scope.raphael_drawings, (obj, key) ->
                obj.remove()
        )

