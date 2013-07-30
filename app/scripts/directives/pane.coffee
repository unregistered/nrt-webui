angular.module("nrtWebuiApp").directive 'paneHorizontal', (ConfigService) ->
    restrict: "A"
    link: (scope, iElement, iAttrs) ->
        panetype = iAttrs.paneHorizontal

        # These are from main.css, units are px
        DIVIDER_WIDTH = 20
        DIVIDER_MARGIN = 10
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

angular.module("nrtWebuiApp").directive 'paneVertical', (ConfigService) ->
    restrict: "A"
    link: (scope, iElement, iAttrs) ->
        panetype = iAttrs.paneVertical

        # These are from main.css, units are px
        DIVIDER_HEIGHT = 20
        DIVIDER_MARGIN = 10
        TOPPANE_TOP_MARGIN = 50

        scope.setPosition = ->
            height = ConfigService.settings.toppane_height
            if panetype is "top"
                iElement.css(
                    height: height
                )
            else if panetype is "bottom"
                iElement.css(
                    top: height + TOPPANE_TOP_MARGIN + DIVIDER_HEIGHT + DIVIDER_MARGIN*2
                )
                scrollHeight = iElement.height() - iElement.find('.panel-heading').height() - 20
                iElement.find('.scrollable').css(
                    height: scrollHeight
                )
                console.log "Set height to", scrollHeight
            else if panetype is "divider"
                iElement.css(
                    top: height + TOPPANE_TOP_MARGIN + DIVIDER_MARGIN
                )

        # Set initial position
        scope.setPosition()

        # left and right panes should watch for changes in leftpane width
        scope.ConfigService = ConfigService
        if panetype is "top" or panetype is "bottom"
            scope.$watch("ConfigService.settings.toppane_height", ->
                scope.setPosition()
            )

        # Divider should be draggable
        if panetype is "divider"
            start_y = 0
            start_page_height = 0
            iElement.draggable(
                axis: 'y'
                start: (evt) ->
                    start_y = evt.pageY
                    start_page_height = ConfigService.settings.toppane_height
                drag: (evt) ->
                    delta_y = evt.pageY - start_y
                    next_pane_height = start_page_height + delta_y
                    # if next_pane_height > ConfigService.UI_PANE_MAXIMUM_HEIGHT # The minimum pane height
                    ConfigService.settings.toppane_height = start_page_height + delta_y
                    scope.$apply()
                    # else
                    #     return false

            )
