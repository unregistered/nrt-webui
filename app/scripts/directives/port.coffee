angular.module("nrtWebuiApp").directive 'port', (UtilityService, ConfigService) ->
    require: ['^raphael', '^module']
    restrict: "E"
    template: """
    <div>Port</div>
    """
    replace: true

    scope: {
        model: "=model"
        index: "@index"
    }
    link: (scope, iElement, iAttrs, controller) ->
        scope.getMsgColor = ->
            UtilityService.str2color(scope.model.msgtype)

        scope.getRetColor = ->
            UtilityService.str2color(scope.model.rettype)

        ###
        Returns object {x, y, w, h}
        The position of the port when its module is at 0,0. This is used to draw the
        position of the box, which will be different for checkers, posters, subscribers.
        ###
        scope.getInitialPosition = ->
            retval = {
                x: 0
                y: 0
                w: 0
                h: 0
            }

            if iAttrs.orientation == 'checker'
                total_width = controller[1].getModel().checkers.length * ( ConfigService.UI_PORT_HEIGHT + ConfigService.UI_PORT_SPACING ) - ConfigService.UI_PORT_SPACING # Last one doesn't get extra space
                midpoint = controller[1].getWidth()/2
                x_start = midpoint - total_width/2 - ConfigService.UI_PORT_HEIGHT

                retval.x = x_start + ConfigService.UI_PORT_HEIGHT + scope.index * (ConfigService.UI_PORT_HEIGHT + ConfigService.UI_PORT_SPACING)
                retval.y = controller[1].getHeight() - ConfigService.UI_PORT_WIDTH/2
                retval.w = ConfigService.UI_PORT_HEIGHT # These are flipped for checkers
                retval.h = ConfigService.UI_PORT_WIDTH
            else
                retval.x = controller[1].getWidth() * (iAttrs.orientation is 'output') - ConfigService.UI_PORT_WIDTH/2
                retval.y = ConfigService.UI_PORT_INITIAL_OFFSET + scope.index * ConfigService.UI_PORT_HEIGHT + ConfigService.UI_PORT_SPACING * scope.index
                retval.w = ConfigService.UI_PORT_WIDTH
                retval.h = ConfigService.UI_PORT_HEIGHT

            return retval

        scope.drawBox = ->
            ip = scope.getInitialPosition()

            rect =  controller[0].paper.rect(ip.x, ip.y, ip.w, ip.h, ConfigService.UI_PORT_BORDER_RADIUS)
            rect.attr
                fill: scope.getMsgColor()

            return rect

        scope.drawRettypeBox = ->
            ip = scope.getInitialPosition()

            if iAttrs.orientation is 'checker'
                # Checkers have no return type
                ip.w = 0
                ip.h = 0
            if iAttrs.orientation is 'input'
                ip.x += ConfigService.UI_PORT_WIDTH/2
                ip.w = ip.w/2
            if iAttrs.orientation is 'output'
                ip.w = ip.w/2

            rect =  controller[0].paper.rect(ip.x, ip.y, ip.w, ip.h, ConfigService.UI_PORT_BORDER_RADIUS)
            rect.attr
                fill: scope.getRetColor()

            return rect

        scope.drawHitbox = ->
            ip = scope.getInitialPosition()

            if iAttrs.orientation is 'checker'
                # Checker adjustments
                ip.x -= ConfigService.UI_PORT_SPACING/2
                ip.h *= 1.5
                ip.w += ConfigService.UI_PORT_SPACING
            else
                # Port adjustments
                ip.y -= ConfigService.UI_PORT_SPACING/2
                ip.x -= 10 if iAttrs.orientation is 'input'
                ip.w = ip.w * 1.5
                ip.h = ip.h + ConfigService.UI_PORT_SPACING

            rect =  controller[0].paper.rect(ip.x, ip.y, ip.w, ip.h, 0)
            rect.attr(
                fill: 'green'
                opacity: 0
            )


        scope.$watch("model", ->
            scope.raphael_drawings = {}
            scope.raphael_drawings.box = scope.drawBox()
            scope.raphael_drawings.rettype_box = scope.drawRettypeBox()
            scope.raphael_drawings.hitbox = scope.drawHitbox()

            c = controller[1].getContainer()
            _.each scope.raphael_drawings, (v, k) ->
                c.push v
        )

