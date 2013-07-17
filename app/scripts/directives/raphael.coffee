angular.module("nrtWebuiApp").directive 'raphael', (ConfigService, SelectionService) ->
    controller: ['$scope', '$element', '$attrs', '$transclude', ($scope, $element, $attrs, $transclude) ->
        @paper = undefined
        @zpd = undefined

        $scope.ivar = "Value"
    ]
    restrict: "E"
    template: """
    <div>
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

        # Draw a mat to intercept multiple selection, these are also the bounds of the program
        mat = controller.paper.rect(-ConfigService.UI_CANVAS_WIDTH/2, -ConfigService.UI_CANVAS_HEIGHT/2, ConfigService.UI_CANVAS_WIDTH, ConfigService.UI_CANVAS_HEIGHT).attr("fill", "#FFF")

        mat.mousedown (event) =>
            SelectionService.clear()
            scope.$apply()

        # Mark the origin
        controller.paper.path("M25,0 L-25,0").attr("stroke", "#ccc")
        controller.paper.path("M0,-25 L0,25").attr("stroke", "#ccc")

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
