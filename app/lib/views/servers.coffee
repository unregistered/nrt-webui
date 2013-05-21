require "nrt-webui/core"

UI_PORT_RADIUS = 7
UI_PORT_INITIAL_OFFSET = 20
UI_PORT_SPACING = 8

UI_CANVAS_WIDTH = 2000
UI_CANVAS_HEIGHT = 1000

UI_MODULE_WIDTH = 100

App.ServerView = Ember.View.extend(
    template: Ember.Handlebars.compile("""
    <div class="row-fluid">
        <div class="span4">
            {{view App.TrayView}}
        </div>
        <div class="span8">
            {{view view.ToolbarView}}
            {{view view.NamespaceView}}
            {{view view.WorkspaceView}}
        </div>
    </div>
    """)

    ToolbarView: Ember.View.extend(
        template: Ember.Handlebars.compile """
            <div class="btn-toolbar">
                <div class="btn-group">
                    {{view view.MoveButton}}
                    {{view view.SelectButton}}
                </div>
            </div>
        """

        MoveButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Move"
            template: Ember.Handlebars.compile """<i class="icon-move"></i>"""

            active: (->
                App.router.settingsController.get('content.canvas_mousemode') == 'drag'
            ).property('App.router.settingsController.content.canvas_mousemode')

            click: ->
                App.router.settingsController.set('content.canvas_mousemode', 'drag')
        )

        SelectButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Multiple Selection"
            template: Ember.Handlebars.compile """<i class="icon-check-empty"></i>"""

            active: (->
                App.router.settingsController.get('content.canvas_mousemode') == 'select'
            ).property('App.router.settingsController.content.canvas_mousemode')

            click: ->
                App.router.settingsController.set('content.canvas_mousemode', 'select')
        )
    )

    NamespaceView: Ember.View.extend(
        template: Ember.Handlebars.compile("""
            <ul class="breadcrumb">
              <li><a href="#">root</a> <span class="divider">/</span></li>
              <li><a href="#">to</a> <span class="divider">/</span></li>
              <li class="active">do</li>
            </ul>
        """)
    )

    WorkspaceView: Ember.View.extend(
        classNames: ['workspace']

        # Panning setting
        classNameBindings: ['moveClass:canvas-drag-mode']
        moveClass: (->
            App.router.settingsController.get('content.canvas_mousemode') == 'drag'
        ).property("App.router.settingsController.content.canvas_mousemode")
        setPan: (->
            @get('zpd').opts.pan = (App.router.settingsController.get('content.canvas_mousemode') == 'drag')
        ).observes('App.router.settingsController.content.canvas_mousemode')

        template: Ember.Handlebars.compile("""
        <div class="hidden">
            {{#each App.router.connectionsController.content}}
                {{view view.Connection connectionBinding="this"}}
            {{/each}}
            {{#each App.router.modulesController.content}}
                {{view view.Module moduleBinding="this"}}
            {{/each}}
        </div>
        """)

        didInsertElement: ->
            el = @$()[0]
            @$().droppable(
                activeClass: "ui-state-active"
                hoverClass: "ui-state-hover"
                drop: (event, ui) =>
                    prototype = $(ui.draggable).data('context')

                    svg_offset = @$().find('svg').offset()
                    adjusted_x = event.clientX - svg_offset.left
                    adjusted_y = event.clientY - svg_offset.top

                    @get('controller').createModule(prototype, adjusted_x, adjusted_y)
            )
            @set 'paper', new Raphael(el, "100%", "100%")
            @set 'zpd', new RaphaelZPD(@get('paper'), {
                zoom: true
                pan: (App.router.settingsController.get('content.canvas_mousemode') == 'drag')
                drag: true
                zoomThreshold: [0.3, 2]
            })

            # Draw a mat to intercept multiple selection, these are also the bounds of the program
            mat = @get('paper').rect(-UI_CANVAS_WIDTH/2, -UI_CANVAS_HEIGHT/2, UI_CANVAS_WIDTH, UI_CANVAS_HEIGHT).attr("fill", "#FFF")
            mat.drag

            selbox =  @get('paper').rect(0, 0, 0, 0);
            color = Raphael.getColor()
            selbox.attr
                fill: color
                stroke: color
                "fill-opacity": 0
                "stroke-width": 2

            @get('paper').draggable = true
            @get('paper').onDragStart = (event) =>
                console.log 'Start drag'
                # @set 'module.dragging', true
                # container.oBB = (
                #     x: @get('module.x')
                #     y: @get('module.y')
                # )

            @get('paper').onDrag = (delta, event) =>
                console.log 'ON drag'
                # obb = container.oBB
                # @get('module').setProperties (
                #     x: Math.round(obb.x + delta.toX - delta.fromX)
                #     y: Math.round(obb.y + delta.toY - delta.fromY)
                # )

            @get('paper').onDragStop = =>
                @set 'module.dragging', false

            # Mark the origin
            @get('paper').path("M25,0 L-25,0").attr("stroke", "#ccc")
            @get('paper').path("M0,-25 L0,25").attr("stroke", "#ccc")

            # Register click event
            $(@get('paper').canvas).bind 'click', (e) =>
                App.router.selectionController.selectCanvas @get('paper')

        Connection: Ember.RaphaelView.extend(
            template: Ember.Handlebars.compile("connection")

            onUpdate: (->
                @get('paper').connection @get('line')
            ).observes('connection.source_module.x', 'connection.source_module.y', 'connection.destination_module.x', 'connection.destination_module.y')

            onModuleSelect: (->
                color = "#000"
                if @get('connection.source_module.selected') || @get('connection.destination_module.selected')
                    color = "#000"
                else
                    if App.router.modulesController.get('selected')
                        color = "#ccc"
                    else
                        color = "#000"

                @get('line').line.attr
                    stroke: color

            ).observes('connection.source_module.selected', 'connection.destination_module.selected')

            didInsertElement: ->
                source = @get 'connection.source_port'
                destination = @get 'connection.destination_port'

                source_view = Ember.View.views[source.get('id')]
                destination_view = Ember.View.views[destination.get('id')]

                @set 'line', @get('paper').connection source_view.get('circle'), destination_view.get('circle')
            willDestroyElement: ->
                @get('line').line.remove()

        )

        Module: Ember.RaphaelView.extend(
            elementId: (->
                @get('module.id')
            ).property('module.moduid')

            template: Ember.Handlebars.compile("""
            Module: {{view.module}}
            {{#each view.module.subscribers}}
                {{view view.Port portBinding="this"}}
            {{/each}}

            {{#each view.module.posters}}
                {{view view.Port portBinding="this"}}
            {{/each}}
            """)

            name: (->
                @get('module.displayName')
            ).property('module.instance', 'module.classname')

            coordx: (->
                # try
                @get('container').getBBox().x
            ).property().volatile()

            coordy: (->
                @get('container').getBBox().y
            ).property().volatile()

            width: (->
                UI_MODULE_WIDTH
            ).property()

            height: (->
                min_height = 150

                posters = @get('module.posters').length
                subscribers = @get('module.subscribers').length

                number_of_ports = Math.max(posters, subscribers)
                port_height = 2*UI_PORT_RADIUS + UI_PORT_SPACING
                computed_height = port_height * number_of_ports + UI_PORT_INITIAL_OFFSET

                return Math.max(computed_height, min_height)
            ).property()

            box: (->
                # The base box
                rect =  @get('paper').rect(0, 0, @get('width'), @get('height'), 7)
                @set('module.width', @get('width'))
                @set('module.height', @get('height'))
                color = Raphael.getColor()
                rect.attr
                    fill: color
                    stroke: color
                    "fill-opacity": 0
                    "stroke-width": 2
                    cursor: "move"

                return rect
            ).property()

            text: (->
                @get('paper').text(50, 50, @get('name'))
            ).property('name')

            container: (->
                # All the objects that will be grouped into a Raphael set
                c = @get('paper').set()
                c.push @get('text')
                c.push @get('box')
                return c
            ).property('box', 'text')

            willDestroyElement: ->
                @get('container').remove()

            beforeRender: ->
                module = @
                container = @get('container')

                box = @get('box')
                box.node.draggable = true
                box.node.onDragStart = (event) =>
                    @set 'module.dragging', true
                    container.oBB = (
                        x: @get('module.x')
                        y: @get('module.y')
                    )

                box.node.onDrag = (delta, event) =>
                    obb = container.oBB

                    nextx = Math.round(obb.x + delta.toX - delta.fromX)
                    nexty = Math.round(obb.y + delta.toY - delta.fromY)

                    # Check bounds
                    if (nextx + UI_MODULE_WIDTH) > UI_CANVAS_WIDTH/2
                        nextx = UI_CANVAS_WIDTH/2 - @get('module.width')
                    else if nextx < -UI_CANVAS_WIDTH/2
                        nextx = -UI_CANVAS_WIDTH/2

                    if (nexty + @get('module.height')) > UI_CANVAS_HEIGHT/2
                        nexty = UI_CANVAS_HEIGHT/2 - @get('module.height')
                    else if nexty < -UI_CANVAS_HEIGHT/2
                        nexty = -UI_CANVAS_HEIGHT/2

                    @get('module').setProperties (
                        x: nextx
                        y: nexty
                    )

                box.node.onDragStop = =>
                    @set 'module.dragging', false

                # container.drag move, dragger, up
                container.mousedown =>
                    App.router.selectionController.selectModule @get('module')
                    $.each module.get('container'), (idx, item) =>
                        item.toFront()

            move: (->
                m = @get('module')
                @moveTo(m.get('x'), m.get('y'))
            ).observes('module.x', 'module.y')

            draggingStatusChanged: (->
                if @get('module.dragging')
                    @get('box').animate "opacity": .6, 200
                else
                    @get('box').animate "opacity": 1, 500
            ).observes('module.dragging')

            selectedStatusChanged: (->
                if @get('module.selected')
                    @get('box').animate "fill-opacity": .2, 500
                else
                    @get('box').animate "fill-opacity": 0, 500

            ).observes('module.selected')

            didInsertElement: ->
                # Move to location
                x = @get('module.x')
                y = @get('module.y')
                @moveTo(x, y)

            moveTo: (x, y) ->
                @get('container').transform("T#{x},#{y}")

            Port: Ember.RaphaelView.extend(
                template: Ember.Handlebars.compile("""
                Port: {{view.port.id}}
                {{#if view.phantomDragging}}
                    {{view view.PhantomPortView}}
                {{/if}}
                """)
                radius: UI_PORT_RADIUS # Radius of each bubble
                initial_offset: UI_PORT_INITIAL_OFFSET # How many pixels to offset the first bubble
                spacing: UI_PORT_SPACING # How many pixels to space each bubble after the first
                containerBinding: 'parentView.container'
                boxBinding: 'parentView.box'
                elementIdBinding: "port.id"
                phantomDragging: false

                isHovered: (->
                    App.router.connectionsController.get('hovered') == @get('port')
                ).property('App.router.connectionsController.hovered')

                willDestroyElement: ->
                    @hideLabel()
                    return true

                toggleHover: (->
                    if @get('isHovered')
                        @showLabel()
                        @get('circle').attr({fill: 'green'})
                    else
                        @get('circle').attr({fill: 'none'})
                        @hideLabel()
                ).observes('isHovered')

                coordx: (->
                    @get('circle').getBBox().x
                ).property().volatile()

                coordy: (->
                    @get('circle').getBBox().y
                ).property().volatile()

                circle: (->
                    xpos = @get('parentView.width') * (@get('port.orientation') is 'output')
                    ypos = @get('initial_offset') + @get('port.index') * (@get('radius') * 2) + @get('spacing') * @get('port.index')
                    circle = @get('paper').circle(xpos, ypos, @get('radius'))
                    circle.node.draggable = false
                    return circle
                ).property()

                showLabel: ->
                    t = @get('paper').text(@get('coordx')+20, @get('coordy'), @get('port.portname'))
                    t.attr (
                        'text-anchor': 'start'
                    )
                    @set 'label', t

                hideLabel: ->
                    try
                        @get('label').remove()
                        @notifyPropertyChange 'label'

                beforeRender: ->
                    c = @get('circle')

                    # Add a tag
                    module = @
                    c.mouseover (arg) =>
                        App.router.connectionsController.set 'hovered', @get('port')

                    c.mouseout (arg) =>
                        App.router.connectionsController.set 'hovered', null

                    # Dragging
                    c.node.draggable = true
                    c.node.onDragStart = (event) =>
                        console.log "start"
                        App.router.connectionsController.startPairing @get('port')

                    c.node.onDrag = (delta, event) =>
                        console.log "Move"

                    c.node.onDragStop = =>
                        console.log "Up", @
                        App.router.connectionsController.completePairing()

                    @get('container').push c

                PhantomPortView: Ember.View.extend(
                    template: Ember.Handlebars.compile "(Phantom Port)"
                )
            )

        )
    )
)
