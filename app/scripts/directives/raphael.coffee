angular.module("nrtWebuiApp").directive 'raphael', ->
    controller: ['$scope', '$element', '$attrs', '$transclude', ($scope, $element, $attrs, $transclude) ->
        ###
        Constants
        ###
        @UI_PORT_BORDER_RADIUS = 4
        @UI_PORT_WIDTH = 20
        @UI_PORT_HEIGHT = 10
        @UI_PORT_INITIAL_OFFSET = 20
        @UI_PORT_SPACING = 8

        @UI_CANVAS_WIDTH = 1000
        @UI_CANVAS_HEIGHT = 1000

        @UI_MODULE_IMAGE_WIDTH = 25

        @UI_CONNECTION_INACTIVE_COLOR = "#ccc"
        @UI_CONNECTION_ACTIVE_COLOR = "#000"

        ###
        iVars
        ###
        @paper = undefined
        @zpd = undefined
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
        mat = controller.paper.rect(-controller.UI_CANVAS_WIDTH/2, -controller.UI_CANVAS_HEIGHT/2, controller.UI_CANVAS_WIDTH, controller.UI_CANVAS_HEIGHT).attr("fill", "#FFF")

        # Mark the origin
        controller.paper.path("M25,0 L-25,0").attr("stroke", "#ccc")
        controller.paper.path("M0,-25 L0,25").attr("stroke", "#ccc")

