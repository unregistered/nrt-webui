###
Sets up the raphael canvas
Provides the Raphael object (paper)
@broadcasts Workspace.select_drag_ended indicates that the user dragged to select
###
angular.module("nrtWebuiApp").directive 'raphael', (ConfigService, SelectionService, ServerService, HoverService, KeyboardShortcutService) ->
    controller: ['$scope', '$element', '$attrs', '$transclude', ($scope, $element, $attrs, $transclude) ->
        @paper = undefined
        @zpd = undefined
    ]
    restrict: "E"
    template: """
    <div class="workspace">
        <div><!--Canvas--></div>
        <div ng-transclude><!--Modules--></div>
    </div>
    """
    replace: true
    transclude: true
    link: (scope, iElement, iAttrs, controller) ->
        canvas_el = iElement.children()[0]

        controller.paper = new Raphael(canvas_el, "100%", "100%")
        controller.zpd = new RaphaelZPD(controller.paper, {
                zoom: true
                pan: true
                drag: true
                zoomThreshold: [0.1, 2]
            })

        # Accept drops
        $(canvas_el).droppable(
            activeClass: "ui-state-active"
            hoverClass: "ui-state-hover"
            drop: (event, ui) =>
                prototype = $(ui.draggable).data('context')

                svg_offset = iElement.find('svg').offset()
                point = {
                    layerX: event.clientX - svg_offset.left
                    layerY: event.clientY - svg_offset.top
                }
                point = controller.zpd.getTransformedPoint(point)

                ServerService.createModule(prototype, point.x, point.y)
        )

        # Draw a mat to intercept multiple selection, these are also the bounds of the program
        mat = controller.paper.rect(-ConfigService.UI_CANVAS_WIDTH/2, -ConfigService.UI_CANVAS_HEIGHT/2, ConfigService.UI_CANVAS_WIDTH, ConfigService.UI_CANVAS_HEIGHT).attr("fill", "#FFF")

        # Clear on click
        mat.mousedown (event) =>
            SelectionService.clear()
            scope.$apply()

        # Hover
        mat.node.onmouseover = ->
            HoverService.clear()
            scope.$apply()

        #
        # Drag to multiply select
        #

        # Initial draggable setting
        mat.node.draggable = (ConfigService.settings.canvas_mousemode == ConfigService.SETTING_CANVAS_MOUSEMODE_SELECT)
        mat.node.onDragStart = (event) =>
            SelectionService.clear()
            scope.$apply()

            p = controller.zpd.getTransformedPoint(event)

            if scope.selbox
                # It's possible for the user to release the mouse outside of the window, so
                # we need to clean up any orphaned select boxes
                scope.selbox.remove()

            scope.selbox = controller.paper.rect(p.x, p.y, 0, 0).attr(
                'stroke': "#9999FF"
                "fill-opacity": 0.2
                'fill': '#9999FF'
            )

        mat.node.onDrag = (delta, event) =>
            box = scope.selbox
            dx = delta.toX - delta.fromX
            dy = delta.toY - delta.fromY
            xoffset = 0
            yoffset = 0

            # If we have negative diff, we need to translate the box, since
            # the rect won't accept a negative width/height
            if dx < 0
                xoffset = dx
                dx = -dx

            if dy < 0
                yoffset = dy
                dy = -dy

            box.transform("T" + xoffset + "," + yoffset)
            box.attr('width', dx)
            box.attr('height', dy)

        mat.node.onDragStop = (event) =>
            # Remove the box, and broadcast the bounds of the box
            box = scope.selbox.getBBox()

            scope.$broadcast("Workspace.select_drag_ended", {
                xlow: box.x
                xhigh: box.x + box.width
                ylow: box.y
                yhigh: box.y + box.height
            })

            scope.selbox.remove()

        # Mark the origin
        controller.paper.path("M25,0 L-25,0").attr("stroke", "#ccc")
        controller.paper.path("M0,-25 L0,25").attr("stroke", "#ccc")

        # Watch for settings changes
        scope.ConfigService = ConfigService
        scope.$watch("ConfigService.settings.canvas_mousemode", ->
            mode = ConfigService.settings.canvas_mousemode

            # We can pan around in drag mode
            controller.zpd.opts.pan = (mode == ConfigService.SETTING_CANVAS_MOUSEMODE_DRAG)

            # We can drag around on the mat when we're in select mode
            mat.node.draggable = (mode == ConfigService.SETTING_CANVAS_MOUSEMODE_SELECT)
        )

        # Watch for changes in zoom and pan
        scope.$on("RequestZoomIn", (arg) ->
            zoom = controller.zpd.getZoomLevel()
            zoom *= 1.1
            controller.zpd.zoomTo(zoom);
        )

        scope.$on("RequestZoomOut", (arg) ->
            zoom = controller.zpd.getZoomLevel()
            zoom *= 0.9
            controller.zpd.zoomTo(zoom);
        )

        scope.$on("RequestPanHome", (arg) ->
            controller.zpd.panTo(0, 0)
        )

        # Keyboard shortcuts
        KeyboardShortcutService.bind "esc", ->
            SelectionService.clear()
            scope.$apply()
