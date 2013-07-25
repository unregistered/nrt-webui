angular.module("nrtWebuiApp").directive 'module', (BlackboardManagerService, UtilityService, SelectionService, ConfigService, LoaderManagerService, $filter, HoverService) ->
    {
        scope: {
            model: "=model"
        }

        controller: ['$scope', '$element', '$attrs', '$transclude', 'ServerService', ($scope, $element, $attrs, $transclude, ServerService) ->
            @getContainer = ->
                $scope.container

            @getWidth = ->
                $scope.getWidth()

            @getHeight = ->
                $scope.getHeight()

            @getModel = ->
                $scope.model

            @updateModulePosition = (module) ->
                ServerService.updateModulePosition module, module.x, module.y
        ]

        require: ["^raphael", "module"] # Get controller from parent directive, and our own controller
        restrict: "E"
        template: """
        <div>
            <div ng-transclude></div>
        </div>
        """
        replace: true
        transclude: true

        link: (scope, iElement, iAttrs, controller) ->
            scope.getWidth = ->
                min_width = 100

                number_of_ports = scope.model.checkers.length
                port_width = ConfigService.UI_PORT_WIDTH + ConfigService.UI_PORT_SPACING
                computed_width = port_width * number_of_ports + ConfigService.UI_PORT_INITIAL_OFFSET

                return Math.max(computed_width, min_width)

            scope.getHeight = ->
                min_height = 150

                posters = scope.model.posters.length
                subscribers = scope.model.subscribers.length

                number_of_ports = Math.max(posters, subscribers)
                port_height = ConfigService.UI_PORT_HEIGHT + ConfigService.UI_PORT_SPACING
                computed_height = port_height * number_of_ports + ConfigService.UI_PORT_INITIAL_OFFSET

                return Math.max(computed_height, min_height)

            scope.getColor = ->
                seed = scope.model.moduid
                return UtilityService.str2color(seed)

            scope.drawBox = ->
                # The base box
                rect =  controller[0].paper.rect(0, 0, scope.getWidth(), scope.getHeight(), 7)
                color = scope.getColor()
                rect.attr
                    fill: color
                    stroke: color
                    "fill-opacity": 0
                    "stroke-width": 2

                return rect

            scope.drawHitbox = ->
                rect = controller[0].paper.rect(0, 0, scope.getWidth(), scope.getHeight())
                rect.attr
                    fill: 'black'
                    opacity: 0
                    cursor: "move"

                return rect

            scope.drawText = ->
                controller[0].paper.text(scope.getWidth()/2, 70, scope.model.classname)

            scope.drawBBNick = ->
                nick = BlackboardManagerService.content[scope.model.bbuid].nick
                controller[0].paper.text( scope.getWidth()/2, scope.getHeight() - 20, nick )

            scope.drawBBNickBackground = ->
                textbbox = scope.raphael_drawings.bbnick.getBBox()
                w = textbbox.width + 10
                h = textbbox.height + 6
                x = scope.getWidth()/2 - w/2
                y = scope.getHeight() - 20 - h/2

                r = controller[0].paper.rect(x, y, w, h, 3)
                r.attr(
                    fill: UtilityService.str2color(scope.model.bbuid)
                    opacity: 0.5
                )
                return r

            scope.imgSrc = ->
                proto = LoaderManagerService.getPrototype(scope.model.bbuid, scope.model.classname)
                return null unless proto
                "data:#{$filter('ext2mime')(proto.iconext)};base64,#{proto.icondata}"

            scope.drawImage = ->
                x = scope.getWidth()/2 - ConfigService.UI_MODULE_IMAGE_WIDTH/2
                y = 30

                src = scope.imgSrc()
                if src
                    # If the user drags in a module, and we already have its prototype
                    return controller[0].paper.image(src, x, y, ConfigService.UI_MODULE_IMAGE_WIDTH, ConfigService.UI_MODULE_IMAGE_WIDTH)
                else
                    # We don't know the prototypes yet, create a small blank image and we'll update it later
                    controller[0].paper.image('', x, y, 0, 0)

            scope.toFront = ->
                _.each scope.container, (it) =>
                    it.toFront()

            scope.moveTo = (x, y) ->
                return unless scope.container
                scope.container.transform("T#{x},#{y}")

            scope.$watch("model", ->
                # Draw
                scope.raphael_drawings = {}
                scope.raphael_drawings.box = scope.drawBox()
                scope.raphael_drawings.text = scope.drawText()
                scope.raphael_drawings.bbnick = scope.drawBBNick()
                scope.raphael_drawings.bbnick_background = scope.drawBBNickBackground()
                scope.raphael_drawings.image = scope.drawImage()
                scope.raphael_drawings.hitbox = scope.drawHitbox()

                # All the objects that will be grouped into a Raphael set
                c = controller[0].paper.set()
                c.push scope.raphael_drawings.text
                c.push scope.raphael_drawings.box
                c.push scope.raphael_drawings.image
                c.push scope.raphael_drawings.bbnick_background
                c.push scope.raphael_drawings.bbnick
                c.push scope.raphael_drawings.hitbox
                scope.container = c

                # Attach dragging event handles
                box = scope.raphael_drawings.hitbox
                box.node.draggable = true
                box.node.onDragStart = (event) =>
                    # For all selected modules, initiate dragging
                    _.each SelectionService.get('module'), (module) =>
                        module._dragging = true
                        module.start_x = module.x
                        module.start_y = module.y

                box.node.onDrag = (delta, event) =>
                    # Update all module positions
                    _.each SelectionService.get('module'), (module) =>
                        dx = delta.toX - delta.fromX
                        dy = delta.toY - delta.fromY

                        nextx = Math.round(module.start_x + dx)
                        nexty = Math.round(module.start_y + dy)

                        # Check bounds
                        if (nextx + module.width) > ConfigService.UI_CANVAS_WIDTH/2
                            nextx = ConfigService.UI_CANVAS_WIDTH/2 - module.width
                        else if nextx < -ConfigService.UI_CANVAS_WIDTH/2
                            nextx = -ConfigService.UI_CANVAS_WIDTH/2

                        if (nexty + module.height) > ConfigService.UI_CANVAS_HEIGHT/2
                            nexty = ConfigService.UI_CANVAS_HEIGHT/2 - module.height
                        else if nexty < -ConfigService.UI_CANVAS_HEIGHT/2
                            nexty = -ConfigService.UI_CANVAS_HEIGHT/2

                        module.y = nexty
                        module.x = nextx

                        controller[1].updateModulePosition(module)

                        scope.$apply()

                box.node.onDragStop = =>
                    # End drag
                    _.each SelectionService.get('module'), (module) =>
                        module._dragging = false

                    scope.$apply()

                box.mouseover ->
                    HoverService.set 'module', scope.model
                    scope.$apply()

                scope.container.mousedown ->
                    if SelectionService.get('module').length > 1
                        # The user is dragging a group of modules
                    else
                        # We can become active
                        SelectionService.set 'module', scope.model
                        scope.toFront()
                        scope.$apply()

            )

            scope.$watch("[model.x, model.y]", (newValue, oldValue, scope) ->
                scope.moveTo(scope.model.x, scope.model.y)
            , true)

            scope.$watch("model._selected", (newValue, oldValue, scope) ->
                window.w =  scope.raphael_drawings.box
                scope.raphael_drawings.box.animate {"fill-opacity": .2}, 500
                if _.contains SelectionService.get('module'), scope.model
                    scope.raphael_drawings.box.animate "fill-opacity": .2, 500
                else
                    scope.raphael_drawings.box.animate "fill-opacity": 0, 500
            )

            scope.$on("Workspace.select_drag_ended", (scopes, message) ->
                # A multiple-select drag ended, check to see if we should be included
                mybbox = scope.raphael_drawings.box.getBBox()
                dragbbox = message

                # We will be selected if the boxes intersect at all
                intersection = ->
                    return false if mybbox.x2 < dragbbox.xlow
                    return false if mybbox.x > dragbbox.xhigh
                    return false if mybbox.y2 < dragbbox.ylow
                    return false if mybbox.y > dragbbox.yhigh
                    return true

                if intersection()
                    SelectionService.append 'module', scope.model
                    scope.$apply()
            )

            # Ensure that modules render on top of everything else
            scope.$on("Connection.last_connection_rendered", ->
                scope.toFront()
            )

            # Update image when we get the prototype data
            scope.$watch("imgSrc()", ->
                src = scope.imgSrc()
                return unless src
                scope.raphael_drawings.image.attr
                    src: src
                    width: ConfigService.UI_MODULE_IMAGE_WIDTH
                    height: ConfigService.UI_MODULE_IMAGE_WIDTH
            )

            # When we're being removed
            iElement.bind('$destroy', ->
                scope.container.remove()
            )
    }
