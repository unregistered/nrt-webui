angular.module("nrtWebuiApp").directive 'module', (ColorizerService) ->
    self = {
        scope: {
            model: "@model"
        }

        raphael_drawings: {}

        require: "^raphael" # Get controller from parent directive
        restrict: "E"
        template: """
        <div>{{model}}</div>
        """
        replace: true
        transclude: true

        link: (scope, iElement, iAttrs, controller) ->
            scope.$watch("model", ->
                self.controller = controller
                self.model = JSON.parse(scope.model)

                console.log "Data changed"
                console.log "Width", self.getWidth(), self.getHeight()

                # Draw
                self.drawBox()
                self.drawText()
                self.drawBBNick()
                self.drawBBNickBackground()
                self.drawHitbox()

                # All the objects that will be grouped into a Raphael set
                c = @controller.paper.set()
                c.push @raphael_drawings.text
                c.push @raphael_drawings.box
                # c.push @raphael_drawings.image
                c.push @raphael_drawings.bbnickBackground
                c.push @raphael_drawings.bbnick
                c.push @raphael_drawings.hitbox
                return c

            )
    }

    self.getWidth = ->
        min_width = 100

        number_of_ports = @model.checkers.length
        port_width = @controller.UI_PORT_WIDTH + @controller.UI_PORT_SPACING
        computed_width = port_width * number_of_ports + @controller.UI_PORT_INITIAL_OFFSET

        return Math.max(computed_width, min_width)

    self.getHeight = ->
        min_height = 150

        posters = @model.posters.length
        subscribers = @model.subscribers.length

        number_of_ports = Math.max(posters, subscribers)
        port_height = @controller.UI_PORT_HEIGHT + @controller.UI_PORT_SPACING
        computed_height = port_height * number_of_ports + @controller.UI_PORT_INITIAL_OFFSET

        return Math.max(computed_height, min_height)

    self.getColor = ->
        seed = @model.moduid
        return ColorizerService.str2color(seed)

    self.drawBox = ->
        # The base box
        rect =  @controller.paper.rect(0, 0, @getWidth(), @getHeight(), 7)
        color = @getColor()
        rect.attr
            fill: color
            stroke: color
            "fill-opacity": 0
            "stroke-width": 2

        @raphael_drawings.box = rect
        return rect

    self.drawHitbox = ->
        rect = @controller.paper.rect(0, 0, @getWidth(), @getHeight())
        rect.attr
            fill: 'black'
            opacity: 0
            cursor: "move"

        @raphael_drawings.hitbox = rect
        return rect

    self.drawText = ->
        @raphael_drawings.text = @controller.paper.text(@getWidth()/2, 70, @model.classname)

    self.drawBBNick = ->
        @raphael_drawings.bbnick = @controller.paper.text( @getWidth()/2, @getHeight() - 20, @model.bbuid )

    self.drawBBNickBackground = ->
        textbbox = @raphael_drawings.bbnick.getBBox()
        w = textbbox.width + 10
        h = textbbox.height + 6
        x = @getWidth()/2 - w/2
        y = @getHeight() - 20 - h/2

        r = @controller.paper.rect(x, y, w, h, 3)
        r.attr(
            fill: ColorizerService.str2color(@model.bbuid)
            opacity: 0.5
        )
        @raphael_drawings.bbnickBackground = r
        return r

    return self
