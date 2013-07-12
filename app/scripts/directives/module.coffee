angular.module("nrtWebuiApp").directive 'module', (ColorizerService) ->
    self = {
        scope: {
            model: "=model"
        }

        require: "^raphael" # Get controller from parent directive
        restrict: "E"
        template: """
        <div>{{model}}</div>
        """
        replace: true
        transclude: true

        link: (scope, iElement, iAttrs, controller) ->
            scope.getWidth = ->
                min_width = 100

                number_of_ports = scope.model.checkers.length
                port_width = controller.UI_PORT_WIDTH + controller.UI_PORT_SPACING
                computed_width = port_width * number_of_ports + controller.UI_PORT_INITIAL_OFFSET

                return Math.max(computed_width, min_width)

            scope.getHeight = ->
                min_height = 150

                posters = scope.model.posters.length
                subscribers = scope.model.subscribers.length

                number_of_ports = Math.max(posters, subscribers)
                port_height = controller.UI_PORT_HEIGHT + controller.UI_PORT_SPACING
                computed_height = port_height * number_of_ports + controller.UI_PORT_INITIAL_OFFSET

                return Math.max(computed_height, min_height)

            scope.getColor = ->
                seed = scope.model.moduid
                return ColorizerService.str2color(seed)

            scope.drawBox = ->
                # The base box
                rect =  controller.paper.rect(0, 0, scope.getWidth(), scope.getHeight(), 7)
                color = scope.getColor()
                rect.attr
                    fill: color
                    stroke: color
                    "fill-opacity": 0
                    "stroke-width": 2

                scope.raphael_drawings.box = rect
                return rect

            scope.drawHitbox = ->
                rect = controller.paper.rect(0, 0, scope.getWidth(), scope.getHeight())
                rect.attr
                    fill: 'black'
                    opacity: 0
                    cursor: "move"

                scope.raphael_drawings.hitbox = rect
                return rect

            scope.drawText = ->
                scope.raphael_drawings.text = controller.paper.text(scope.getWidth()/2, 70, scope.model.classname)

            scope.drawBBNick = ->
                scope.raphael_drawings.bbnick = controller.paper.text( scope.getWidth()/2, scope.getHeight() - 20, scope.model.bbuid )

            scope.drawBBNickBackground = ->
                textbbox = scope.raphael_drawings.bbnick.getBBox()
                w = textbbox.width + 10
                h = textbbox.height + 6
                x = scope.getWidth()/2 - w/2
                y = scope.getHeight() - 20 - h/2

                r = controller.paper.rect(x, y, w, h, 3)
                r.attr(
                    fill: ColorizerService.str2color(scope.model.bbuid)
                    opacity: 0.5
                )
                scope.raphael_drawings.bbnickBackground = r
                return r

            scope.moveTo = (x, y) ->
                return unless scope.container
                scope.container.transform("T#{x},#{y}")

            scope.$watch("model", ->
                console.log "Data changed"
                console.log "Width", scope.getWidth(), scope.getHeight()

                # Draw
                scope.raphael_drawings = {}
                scope.raphael_drawings.box = scope.drawBox()
                scope.drawText()
                scope.drawBBNick()
                scope.drawBBNickBackground()
                scope.drawHitbox()

                # All the objects that will be grouped into a Raphael set
                c = controller.paper.set()
                c.push scope.raphael_drawings.text
                c.push scope.raphael_drawings.box
                # c.push scope.raphael_drawings.image
                c.push scope.raphael_drawings.bbnickBackground
                c.push scope.raphael_drawings.bbnick
                c.push scope.raphael_drawings.hitbox
                scope.container = c

                # Attach dragging event handles
                scope.selectedModules = [scope.model]
                box = scope.raphael_drawings.hitbox
                box.node.draggable = true
                box.node.onDragStart = (event) =>
                    console.log "Drag start"
                    _.each scope.selectedModules, (module) =>
                        module.dragging = true
                        module.start_x = module.x
                        module.start_y = module.y

                box.node.onDrag = (delta, event) =>
                    console.log "On drag"
                    _.each scope.selectedModules, (module) =>
                        dx = delta.toX - delta.fromX
                        dy = delta.toY - delta.fromY

                        nextx = Math.round(module.start_x + dx)
                        nexty = Math.round(module.start_y + dy)

                        # Check bounds
                        if (nextx + module.width) > controller.UI_CANVAS_WIDTH/2
                            nextx = controller.UI_CANVAS_WIDTH/2 - module.width
                        else if nextx < -controller.UI_CANVAS_WIDTH/2
                            nextx = -controller.UI_CANVAS_WIDTH/2

                        if (nexty + module.height) > controller.UI_CANVAS_HEIGHT/2
                            nexty = controller.UI_CANVAS_HEIGHT/2 - module.height
                        else if nexty < -controller.UI_CANVAS_HEIGHT/2
                            nexty = -controller.UI_CANVAS_HEIGHT/2

                        scope.model.y = nexty
                        scope.model.x = nextx

                        scope.$apply()

                box.node.onDragStop = =>
                    console.log "Drag stop"
                    scope.$apply()
                    console.log scope
                    _.each scope.selectedModules, (module) =>
                        module.dragging = false
            )

            scope.$watch("[model.x, model.y]", (newValue, oldValue, scope) ->
                console.log "Position moved", scope.model.x, scope.model.y
                scope.moveTo(scope.model.x, scope.model.y)
            , true)
    }
