angular.module("nrtWebuiApp").directive 'pane', (ConfigService) ->
    restrict: "A"
    link: (scope, iElement, iAttrs) ->
        panetype = iAttrs.pane

        # These are from main.css, units are px
        DIVIDER_WIDTH = 20
        DIVIDER_MARGIN = 5
        LEFTPANE_LEFT_MARGIN = 40

        scope.setPosition = ->
            lwidth = ConfigService.settings.leftpane_width
            if panetype is "leftpane"
                iElement.css(
                    width: lwidth
                )
            else if panetype is "rightpane"
                iElement.css(
                    left: lwidth + LEFTPANE_LEFT_MARGIN + DIVIDER_WIDTH + DIVIDER_MARGIN*2
                )
            else if panetype is "divider"
                iElement.css(
                    left: lwidth + LEFTPANE_LEFT_MARGIN + DIVIDER_MARGIN
                )

        # Set initial position
        scope.setPosition()

        # left and right panes should watch for changes in leftpane width
        scope.ConfigService = ConfigService
        if panetype is "leftpane" or panetype is "rightpane"
            scope.$watch("ConfigService.settings.leftpane_width", ->
                scope.setPosition()
            )

        # Divider should be draggable
        if panetype is "divider"
            start_x = 0
            start_pane_width = 0
            iElement.draggable(
                axis: 'x'
                start: (evt) ->
                    start_x = evt.pageX
                    start_pane_width = ConfigService.settings.leftpane_width
                drag: (evt) ->
                    delta_x = evt.pageX - start_x
                    next_pane_width = start_pane_width + delta_x
                    if next_pane_width > ConfigService.UI_PANE_MINIMUM_WIDTH # The minimum pane width
                        ConfigService.settings.leftpane_width = start_pane_width + delta_x
                        scope.$apply()
                    else
                        return false

            )
