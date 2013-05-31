require "nrt-webui/core"

UI_PORT_BORDER_RADIUS = 4
UI_PORT_WIDTH = 20
UI_PORT_HEIGHT = 10
UI_PORT_INITIAL_OFFSET = 20
UI_PORT_SPACING = 8

UI_CANVAS_WIDTH = 100000
UI_CANVAS_HEIGHT = 100000

UI_MODULE_IMAGE_WIDTH = 25

UI_CONNECTION_INACTIVE_COLOR = "#ccc"
UI_CONNECTION_ACTIVE_COLOR = "#000"

Ember.RaphaelView = Ember.View.extend(
    tagName: 'li'
    paperBinding: "parentView.paper"
)

App.ServerView = Ember.View.extend(
    template: Ember.Handlebars.compile("""
    <div class="row-fluid">
        <div class="span4">
            {{view App.TrayView}}
        </div>
        <div class="span8">
            {{view view.AlertView}}
            {{view view.ToolbarView}}
            {{view view.NamespaceView}}
            {{view view.WorkspaceView}}
        </div>
    </div>
    """)

    AlertView: Ember.View.extend(
        classNames: ["alert"]
        classNameBindings: ['alertType', 'isHidden:hidden']
        alertType: (->
            return 'alert-error'
        ).property()

        isHidden: (->
            return @get('controller.content.connected')
        ).property("controller.content.connected")

        template: Ember.Handlebars.compile """
        <strong>Error</strong>
        <p>NRT Designer has lost its connection to the master loader.</p>
        <p>Reason: {{controller.content.disconnection_reason}}</p>
        <p>Reload the page to try again.</p>
        """
    )

    ToolbarView: Ember.View.extend(
        template: Ember.Handlebars.compile """
            <div class="btn-toolbar">
                <div class="btn-group">
                    {{view view.RestoreViewButton}}
                    {{view view.ZoomInButton}}
                    {{view view.ZoomOutButton}}
                </div>
                <div class="btn-group">
                    {{view view.MoveButton}}
                    {{view view.SelectButton}}
                </div>
                {{view view.StopButton}}
                {{view view.StartButton}}
            </div>
        """

        RestoreViewButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Move"
            template: Ember.Handlebars.compile """<i class="icon-home"></i>"""

            click: ->
                App.router.canvasController.panToCenter()
        )

        ZoomInButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Move"
            template: Ember.Handlebars.compile """<i class="icon-zoom-in"></i>"""

            click: ->
                App.router.canvasController.zoomIn()
        )

        ZoomOutButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Move"
            template: Ember.Handlebars.compile """<i class="icon-zoom-out"></i>"""

            click: ->
                App.router.canvasController.zoomOut()
        )

        StartButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small', 'pull-right']
            classNameBindings: ['color']
            attributeBindings: ['title']
            title: "Start"
            template: Ember.Handlebars.compile """Start"""

            color: (->
                return 'btn-success'
            ).property()

            click: (->
                App.router.serverController.start()
            )
        )

        StopButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small', 'pull-right']
            classNameBindings: ['color']
            attributeBindings: ['title']
            title: "Start"
            template: Ember.Handlebars.compile """Stop"""

            color: (->
                return 'btn-danger'
            ).property()

            click: (->
                App.router.serverController.stop()
            )
        )

        MoveButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Move"
            template: Ember.Handlebars.compile """<i class="icon-move"></i>"""

            active: (->
                App.router.settingsController.get('content.canvas_mousemode') == App.SETTING_CANVAS_MOUSEMODE_DRAG
            ).property('App.router.settingsController.content.canvas_mousemode')

            click: ->
                App.router.settingsController.set('content.canvas_mousemode', App.SETTING_CANVAS_MOUSEMODE_DRAG)
        )

        SelectButton: Ember.View.extend(
            tagName: 'a'
            classNames: ['btn', 'btn-small']
            classNameBindings: ['active']
            attributeBindings: ['title']
            title: "Multiple Selection"
            template: Ember.Handlebars.compile """<i class="icon-check-empty"></i>"""

            active: (->
                App.router.settingsController.get('content.canvas_mousemode') == App.SETTING_CANVAS_MOUSEMODE_SELECT
            ).property('App.router.settingsController.content.canvas_mousemode')

            click: ->
                App.router.settingsController.set('content.canvas_mousemode', App.SETTING_CANVAS_MOUSEMODE_SELECT)
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
        zpdBinding: "App.router.canvasController.zpd"

        # Panning setting
        classNameBindings: ['moveClass:canvas-drag-mode']
        moveClass: (->
            App.router.settingsController.get('content.canvas_mousemode') == App.SETTING_CANVAS_MOUSEMODE_DRAG
        ).property("App.router.settingsController.content.canvas_mousemode")
        mouseModeChanged: (->
            mode = App.router.settingsController.get('content.canvas_mousemode')

            # We can pan around in drag mode
            @get('zpd').opts.pan = (mode == App.SETTING_CANVAS_MOUSEMODE_DRAG)

            # We can drag around on the mat when we're in select mode
            @get('mat').node.draggable = (mode == App.SETTING_CANVAS_MOUSEMODE_SELECT)
        ).observes('App.router.settingsController.content.canvas_mousemode')

        template: Ember.Handlebars.compile("""
        <div class="hidden">
            {{#each App.router.modulesController.content}}
                {{view view.Module moduleBinding="this"}}
            {{/each}}
            {{#each App.router.connectionsController.content}}
                {{view view.Connection connectionBinding="this"}}
            {{/each}}
            {{#each App.router.connectionsController.candidateConnections}}
                {{view view.Connection connectionBinding="this" phantom="true"}}
            {{/each}}
        </div>
        """)

        # Scales point to zoomed point. Event should contain members layerX and layerY
        transformedPoint: (event) ->
            # ZPD expects an event with layerX and layerY as x and y
            # Get an SVGPoint object, which has the matrixTransform method
            p = @get('zpd').getEventPoint(event)

            svgDoc = @$().find('svg')[0]
            g = svgDoc.getElementById("viewport"+@get('zpd').id);

            # See raphael-zpd plugin for details
            p = p.matrixTransform(g.getCTM().inverse());
            return p

        workspaceResizeObserver: (->
            newHeight = Window.get('height') - @$().offset().top - 20;
            @$().height(newHeight)
        ).observes('Window.height')

        didInsertElement: ->
            el = @$()[0]

            Ember.run.later(@, (->
                @workspaceResizeObserver()
            ), 1000)

            # Accept drops
            @$().droppable(
                activeClass: "ui-state-active"
                hoverClass: "ui-state-hover"
                drop: (event, ui) =>
                    prototype = $(ui.draggable).data('context')

                    svg_offset = @$().find('svg').offset()
                    point = {
                        layerX: event.clientX - svg_offset.left
                        layerY: event.clientY - svg_offset.top
                    }
                    point = @transformedPoint(point)

                    @get('controller').createModule(prototype, point.x, point.y)
            )
            @set 'paper', new Raphael(el, "100%", "100%")
            App.router.canvasController.set 'zpd', new RaphaelZPD(@get('paper'), {
                zoom: true
                pan: (App.router.settingsController.get('content.canvas_mousemode') == App.SETTING_CANVAS_MOUSEMODE_DRAG)
                drag: true
                zoomThreshold: [0.1, 2]
            })
            App.router.canvasController.set 'svg', @$().find('svg')[0]

            # Draw a mat to intercept multiple selection, these are also the bounds of the program
            @set 'mat', @get('paper').rect(-UI_CANVAS_WIDTH/2, -UI_CANVAS_HEIGHT/2, UI_CANVAS_WIDTH, UI_CANVAS_HEIGHT).attr("fill", "#FFF")

            # Deselect when the canvas is clicked
            @get('mat').mousedown (event) =>
                App.router.selectionController.clearSelection()

            # Allow dragging of the canvas to multiply select things
            @get('mat').node.draggable = (App.router.settingsController.get('content.canvas_mousemode') == App.SETTING_CANVAS_MOUSEMODE_SELECT)
            @get('mat').node.onDragStart = (event) =>
                App.router.selectionController.clearSelection()

                p = @transformedPoint(event)

                if @get('selbox')
                    # It's possible for the user to release the mouse outside of the window, so
                    # we need to clean up any orphaned select boxes
                    @get('selbox').remove()

                @set 'selbox', @get('paper').rect(p.x, p.y, 0, 0).attr(
                    'stroke': "#9999FF"
                    "fill-opacity": 0.2
                    'fill': '#9999FF'
                )

            @get('mat').node.onDrag = (delta, event) =>
                box = @get('selbox')
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

            @get('mat').node.onDragStop = (event) =>
                # Remove the box, and find who was selected
                box = @get('selbox').getBBox()
                xlow = box.x
                xhigh = xlow + box.width
                ylow = box.y
                yhigh = ylow + box.height

                mods = App.router.modulesController.content.filter (item) ->
                    x = item.get('x')
                    y = item.get('y')
                    (x > xlow && x < xhigh && y > ylow && y < yhigh) # In the bounding box

                App.router.selectionController.setSelection mods

                @get('selbox').remove()

            # Mark the origin
            @get('paper').path("M25,0 L-25,0").attr("stroke", "#ccc")
            @get('paper').path("M0,-25 L0,25").attr("stroke", "#ccc")

        Connection: Ember.RaphaelView.extend(
            template: Ember.Handlebars.compile("connection")
            start: null
            end: null
            phantom: false # Phantom connections are not yet real

            curved_path_string: (->
                bb1 = @get('start_view').get('bbox')
                bb2 = @get('end_view').get('bbox')

                p = [
                  x: bb1.x + bb1.width / 2
                  y: bb1.y - 1
                ,
                  x: bb1.x + bb1.width / 2
                  y: bb1.y + bb1.height + 1
                ,
                  x: bb1.x - 1
                  y: bb1.y + bb1.height / 2
                ,
                  x: bb1.x + bb1.width + 1
                  y: bb1.y + bb1.height / 2
                ,
                  x: bb2.x + bb2.width / 2
                  y: bb2.y - 1
                ,
                  x: bb2.x + bb2.width / 2
                  y: bb2.y + bb2.height + 1
                ,
                  x: bb2.x - 1
                  y: bb2.y + bb2.height / 2
                ,
                  x: bb2.x + bb2.width + 1
                  y: bb2.y + bb2.height / 2
                ]
                d = {}
                dis = []
                i = 0

                while i < 4
                  j = 4

                  while j < 8
                    dx = Math.abs(p[i].x - p[j].x)
                    dy = Math.abs(p[i].y - p[j].y)
                    if (i is j - 4) or (((i isnt 3 and j isnt 6) or p[i].x < p[j].x) and ((i isnt 2 and j isnt 7) or p[i].x > p[j].x) and ((i isnt 0 and j isnt 5) or p[i].y > p[j].y) and ((i isnt 1 and j isnt 4) or p[i].y < p[j].y))
                      dis.push dx + dy
                      d[dis[dis.length - 1]] = [i, j]
                    j++
                  i++
                if dis.length is 0
                  res = [0, 4]
                else
                  res = d[Math.min.apply(Math, dis)]
                x1 = p[res[0]].x
                y1 = p[res[0]].y
                x4 = p[res[1]].x
                y4 = p[res[1]].y
                dx = Math.max(Math.abs(x1 - x4) / 2, 10)
                dy = Math.max(Math.abs(y1 - y4) / 2, 10)
                x2 = [x1, x1, x1 - dx, x1 + dx][res[0]].toFixed(3)
                y2 = [y1 - dy, y1 + dy, y1, y1][res[0]].toFixed(3)
                x3 = [0, 0, 0, 0, x4, x4, x4 - dx, x4 + dx][res[1]].toFixed(3)
                y3 = [0, 0, 0, 0, y1 + dy, y1 - dy, y4, y4][res[1]].toFixed(3)
                path = ["M", x1.toFixed(3), y1.toFixed(3), "C", x2, y2, x3, y3, x4.toFixed(3), y4.toFixed(3)].join(",")
            ).property('connection.source_module.x', 'connection.source_module.y', 'connection.destination_module.x', 'connection.destination_module.y')

            straight_path_string: (->
                bb1 = @get('start_view').get('bbox')
                bb2 = @get('end_view').get('bbox')

                x1 = bb1.x + bb1.width/2
                y1 = bb1.y + bb1.height/2

                x2 = bb2.x + bb2.width/2
                y2 = bb2.y + bb2.height/2

                return "M," + x1.toFixed(3) + "," + y1.toFixed(3) + ",L," + x2.toFixed(3) + "," + y2.toFixed(3)
            ).property('connection.source_module.x', 'connection.source_module.y', 'connection.destination_module.x', 'connection.destination_module.y')

            ###
            Choose between path appearances.
            ###
            path_string: (->
                if @get('connection.source_module.dragging') or @get('connection.destination_module.dragging')
                    return @get('straight_path_string')
                else
                    return @get('curved_path_string')
            ).property('connection.source_module.dragging', 'connection.destination_module.dragging', 'curved_path_string', 'straight_path_string')

            pathUpdater: (->
                @get('line').attr(path: @get('path_string'))
                @get('hitbox').attr(path: @get('path_string'))
            ).observes('path_string')

            onConnectionSelect: (->
                w = if @get('connection.selected') then 3 else 1
                @get('line').attr(
                    'stroke-width': w
                )
            ).observes('connection.selected')

            onModuleSelect: (->
                color = UI_CONNECTION_ACTIVE_COLOR
                if @get('connection.source_module.selected') || @get('connection.destination_module.selected')
                    color = UI_CONNECTION_ACTIVE_COLOR
                else
                    if App.router.selectionController.get('content.length')
                        color = UI_CONNECTION_INACTIVE_COLOR
                    else
                        color = UI_CONNECTION_ACTIVE_COLOR

                @get('line').attr
                    stroke: color

            ).observes('connection.source_module.selected', 'connection.destination_module.selected')

            # onPhantomHover: (->
            #     if @get('phantom') && (App.router.connectionsController.get('hovered') == @get('connection'))
            #         @get('line').attr(
            #             stroke: UI_CONNECTION_ACTIVE_COLOR
            #         )
            #     else
            #         @get('line').attr(
            #             stroke: UI_CONNECTION_INACTIVE_COLOR
            #         )
            # ).observes('App.router.connectionsController.hovered')

            line: (->
                l = @get('paper').path(@get('path_string'))
                l.attr(
                    stroke: UI_CONNECTION_INACTIVE_COLOR
                    'stroke-width': 1
                    fill: "none"
                )

                if @get('phantom')
                    l.attr('stroke-dasharray': '--')

                return l
            ).property()

            hitbox: (->
                b = @get('paper').path(@get('path_string'))
                b.attr(
                    stroke: UI_CONNECTION_ACTIVE_COLOR
                    'stroke-width': 10
                    'stroke-opacity': 0
                )
                return b
            ).property()

            didInsertElement: ->
                source = @get 'connection.source_port'
                destination = @get 'connection.destination_port'

                source_view = Ember.View.views[source.get('id')]
                destination_view = Ember.View.views[destination.get('id')]

                @set 'start_view', source_view
                @set 'end_view', destination_view

                # Draw the line
                @get('line')

                # Allow for selection
                @get('hitbox').mousedown =>
                    App.router.selectionController.setSelection(@get('connection'))

                # Allow for easy connection creation by hovering
                if @get('phantom')
                    @get('hitbox').mouseover =>
                        @get('line').attr(
                            stroke: UI_CONNECTION_ACTIVE_COLOR
                        )
                        App.router.connectionsController.set 'hovered', @get('connection.destination_port')
                    .mouseout =>
                        # line may not exist if we made a successful connection and delete ourself
                        @get('line') && @get('line').attr(
                            stroke: UI_CONNECTION_INACTIVE_COLOR
                        )
                        App.router.connectionsController.set 'hovered', false

            willDestroyElement: ->
                @get('hitbox').remove()
                @get('line').remove()

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

            {{#each view.module.checkers}}
                {{view view.Port portBinding="this"}}
            {{/each}}
            """)

            name: (->
                @get('module.displayName')
            ).property('module.instance', 'module.classname')

            bbox: (->
                @get('container').getBBox()
            )

            width: (->
                min_width = 100

                number_of_ports = @get('module.checkers.length')
                port_width = UI_PORT_WIDTH + UI_PORT_SPACING
                computed_width = port_width * number_of_ports + UI_PORT_INITIAL_OFFSET

                return Math.max(computed_width, min_width)
            ).property()

            height: (->
                min_height = 150

                posters = @get('module.posters').length
                subscribers = @get('module.subscribers').length

                number_of_ports = Math.max(posters, subscribers)
                port_height = UI_PORT_HEIGHT + UI_PORT_SPACING
                computed_height = port_height * number_of_ports + UI_PORT_INITIAL_OFFSET

                return Math.max(computed_height, min_height)
            ).property()

            box: (->
                # The base box
                rect =  @get('paper').rect(0, 0, @get('width'), @get('height'), 7)
                @set('module.width', @get('width'))
                @set('module.height', @get('height'))
                color = @get('color')
                rect.attr
                    fill: color
                    stroke: color
                    "fill-opacity": 0
                    "stroke-width": 2

                return rect
            ).property()

            hitbox: (->
                rect = @get('paper').rect(0, 0, @get('width'), @get('height'))
                rect.attr
                    fill: 'black'
                    opacity: 0
                    cursor: "move"

                return rect
            ).property()

            color: (->
                seed = @get('module.moduid')
                App.str2color(seed)
            ).property('module.moduid')

            text: (->
                @get('paper').text(@get('width')/2, 70, @get('name'))
            ).property('name')

            bbnick: (->
                @get('paper').text( @get('width')/2, @get('height') - 20, @get('module.blackboard.bbnick') )
            ).property()
            bbnickBackground: (->
                textbbox = @get('bbnick').getBBox()
                w = textbbox.width + 10
                h = textbbox.height + 6
                x = @get('width')/2 - w/2
                y = @get('height') - 20 - h/2

                r = @get('paper').rect(x, y, w, h, 3)
                r.attr(
                    fill: App.str2color(@get('module.blackboard.bbnick'))
                    opacity: 0.5
                )
                return r
            ).property()

            imagesrc: (->
                proto = App.router.prototypesController.get('content').findProperty 'classname', @get('module.classname')
                return null unless proto

                return proto.get('src')
            ).property('App.router.prototypesController.content.@each', 'module.classname')

            image: (->
                x = @get('width')/2 - UI_MODULE_IMAGE_WIDTH/2
                y = 30

                src = @get('imagesrc')
                if src
                    # If the user drags in a module, and we already have its prototype
                    return @get('paper').image(src, x, y, UI_MODULE_IMAGE_WIDTH, UI_MODULE_IMAGE_WIDTH)
                else
                    # We don't know the prototypes yet, create a small blank image and we'll update it later
                    @get('paper').image('', x, y, 0, 0)
            ).property()

            imageUpdater: (->
                src = @get('imagesrc')
                return unless src

                @get('image').attr
                    src: src
                    width: UI_MODULE_IMAGE_WIDTH
                    height: UI_MODULE_IMAGE_WIDTH
            ).observes('imagesrc')

            container: (->
                # All the objects that will be grouped into a Raphael set
                c = @get('paper').set()
                c.push @get('text')
                c.push @get('box')
                c.push @get('image')
                c.push @get('bbnickBackground')
                c.push @get('bbnick')
                c.push @get('hitbox')
                return c
            ).property('box', 'text', 'image', 'hitbox')

            selectedModules: (->
                selection = App.router.selectionController.get('content')
                selection.filter (item) =>
                    item instanceof App.Module
            ).property('App.router.selectionController.content.@each')

            isPartOfMultipleSelection: (->
                modules = @get('selectedModules')
                return modules.contains(@get('module')) && (modules.get('length') > 1)
            ).property('selectedModules')

            willDestroyElement: ->
                @get('container').remove()

            beforeRender: ->
                module = @
                container = @get('container')

                box = @get('hitbox')
                box.node.draggable = true
                box.node.onDragStart = (event) =>
                    @get('selectedModules').forEach (module) =>
                        module.set 'dragging', true
                        module.set 'start_x', module.get('x')
                        module.set 'start_y', module.get('y')

                box.node.onDrag = (delta, event) =>
                    @get('selectedModules').forEach (module) =>
                        dx = delta.toX - delta.fromX
                        dy = delta.toY - delta.fromY

                        nextx = Math.round(module.get('start_x') + dx)
                        nexty = Math.round(module.get('start_y') + dy)

                        # Check bounds
                        if (nextx + module.get('width')) > UI_CANVAS_WIDTH/2
                            nextx = UI_CANVAS_WIDTH/2 - module.get('width')
                        else if nextx < -UI_CANVAS_WIDTH/2
                            nextx = -UI_CANVAS_WIDTH/2

                        if (nexty + module.get('height')) > UI_CANVAS_HEIGHT/2
                            nexty = UI_CANVAS_HEIGHT/2 - module.get('height')
                        else if nexty < -UI_CANVAS_HEIGHT/2
                            nexty = -UI_CANVAS_HEIGHT/2

                        module.setProperties (
                            x: nextx
                            y: nexty
                        )

                box.node.onDragStop = =>
                    @get('selectedModules').forEach (module) =>
                        module.set 'dragging', false

                # container.drag move, dragger, up
                container.mousedown =>
                    if @get('isPartOfMultipleSelection')
                        # The user in dragging a group of modules
                    else
                        # Then we can become active
                        App.router.selectionController.setSelection @get('module')
                        $.each module.get('container'), (idx, item) =>
                            item.toFront()

                box.hover =>
                    @get('container').toFront()

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
                if App.router.selectionController.get('content').contains(@get('module'))
                    @get('box').animate "fill-opacity": .2, 500
                else
                    @get('box').animate "fill-opacity": 0, 500

            ).observes('App.router.selectionController.content.@each')

            didInsertElement: ->
                # Move to location
                x = @get('module.x')
                y = @get('module.y')
                @moveTo(x, y)
                @get('container').toFront()

            moveTo: (x, y) ->
                @get('container').transform("T#{x},#{y}")

            Port: Ember.RaphaelView.extend(
                template: Ember.Handlebars.compile("""
                Port: {{view.port.id}}
                """)
                paperBinding: 'parentView.paper'
                containerBinding: 'parentView.container'
                boxBinding: 'parentView.box'
                elementIdBinding: "port.id"

                isHovered: (->
                    App.router.connectionsController.get('hovered') == @get('port')
                ).property('App.router.connectionsController.hovered')

                willDestroyElement: ->
                    @hideLabel()
                    return true

                msgColor: (->
                    App.str2color(@get('port.msgtype'))
                ).property('port.msgtype')

                retColor: (->
                    App.str2color(@get('port.rettype'))
                ).property('port.rettype')

                toggleLabel: (->
                    if @get('isHovered')
                        @showLabel()
                    else
                        @hideLabel()
                ).observes('isHovered')

                hoverObserver: (->
                    if @get('isHovered')
                        @get('box').attr(
                            opacity: 0.5
                        )
                        @get('rettype_box').attr(
                            opacity: 0.5
                        )
                    else
                        @get('box').attr(
                            opacity: 1
                        )
                        @get('rettype_box').attr(
                            opacity: 1
                        )
                ).observes('isHovered')

                selectionObserver: (->
                    if App.router.selectionController.get('content').contains @get('port')
                        @get('box').attr(
                            'stroke': 'black'
                            'stroke-width': 2
                        )
                    else
                        @get('box').attr(
                            'stroke': 'black'
                            'stroke-width': 1
                        )
                ).observes('App.router.selectionController.content.@each')

                onPairing: (->
                    if App.router.connectionsController.get('candidatePorts').contains @get('port')
                        # Show our hitbox
                        @get('hitbox').attr(
                            'fill': 'green'
                            opacity: 0.2
                        )
                    else
                        @get('hitbox').attr(
                            'fill': 'green'
                            opacity: 0
                        )
                ).observes('App.router.connectionsController.candidatePorts')

                bbox: (->
                    @get('box').getBBox()
                ).property().volatile()

                ###
                Returns object {x, y, w, h}
                The position of the port when its module is at 0,0. This is used to draw the
                position of the box, which will be different for checkers, posters, subscribers.
                ###
                initial_position: (->
                    retval = {
                        x: 0
                        y: 0
                        w: 0
                        h: 0
                    }

                    if @get('port.orientation') == 'checker'
                        total_width = @get('port.module.checkers.length') * ( UI_PORT_HEIGHT + UI_PORT_SPACING ) - UI_PORT_SPACING # Last one doesn't get extra space
                        midpoint = @get('parentView.width')/2
                        x_start = midpoint - total_width/2 - UI_PORT_HEIGHT

                        retval.x = x_start + UI_PORT_HEIGHT + @get('port.index') * (UI_PORT_HEIGHT + UI_PORT_SPACING)
                        retval.y = @get('parentView.height') - UI_PORT_WIDTH/2
                        retval.w = UI_PORT_HEIGHT # These are flipped for checkers
                        retval.h = UI_PORT_WIDTH
                    else
                        retval.x = @get('parentView.width') * (@get('port.orientation') is 'output') - UI_PORT_WIDTH/2
                        retval.y = UI_PORT_INITIAL_OFFSET + @get('port.index') * UI_PORT_HEIGHT + UI_PORT_SPACING * @get('port.index')
                        retval.w = UI_PORT_WIDTH
                        retval.h = UI_PORT_HEIGHT

                    return retval
                ).property()

                box: (->
                    x = @get('initial_position').x
                    y = @get('initial_position').y
                    w = @get('initial_position').w
                    h = @get('initial_position').h

                    rect =  @get('paper').rect(x, y, w, h, UI_PORT_BORDER_RADIUS)
                    rect.attr
                        fill: @get('msgColor')

                    return rect

                ).property()

                # UI element representing the return type
                rettype_box: (->
                    x = @get('initial_position').x
                    y = @get('initial_position').y
                    w = @get('initial_position').w
                    h = @get('initial_position').h

                    if @get('port.orientation') is 'checker'
                        # Checkers have no return type
                        w = 0
                        h = 0
                    if @get('port.orientation') is 'input'
                        x += UI_PORT_WIDTH/2
                        w = w/2
                    if @get('port.orientation') is 'output'
                        w = w/2

                    rect =  @get('paper').rect(x, y, w, h, UI_PORT_BORDER_RADIUS)
                    rect.attr
                        fill: @get('retColor')

                    return rect
                ).property()

                hitbox: (->
                    x = @get('initial_position').x
                    y = @get('initial_position').y
                    w = @get('initial_position').w
                    h = @get('initial_position').h

                    if @get('port.orientation') is 'checker'
                        # Checker adjustments
                        x -= UI_PORT_SPACING/2
                        h *= 1.5
                        w += UI_PORT_SPACING
                    else
                        # Port adjustments
                        y -= UI_PORT_SPACING/2
                        x -= 10 if @get('port.orientation') is 'input'
                        w = w * 1.5
                        h = h + UI_PORT_SPACING

                    rect =  @get('paper').rect(x, y, w, h, 0)
                    rect.attr(
                        fill: 'green'
                        opacity: 0
                    )
                ).property()

                showLabel: ->
                    textmsg = "#{@get('port.portname')}\n    Msg: #{@get('port.msgtype')}\n    Ret: #{@get('port.rettype')}"
                    x = @get('bbox').x + 30
                    y = @get('bbox').y
                    t = @get('paper').text(x, y, textmsg)
                    t.attr (
                        'text-anchor': 'start'
                        fill: 'white'
                    )

                    w = t.getBBox().width + 10
                    h = t.getBBox().height + 10
                    x = x - 10/2
                    y = y - h/2

                    tb = @get('paper').rect(x, y, w, h, 3)
                    tb.attr(
                        fill: 'black'
                    )

                    t.toFront()

                    @set 'label', t
                    @set 'labelBackground', tb

                hideLabel: ->
                    try
                        @get('label').remove()
                    try
                        @get('labelBackground').remove()
                    try
                        @notifyPropertyChange 'label'

                beforeRender: ->
                    box = @get('box')
                    hitbox = @get('hitbox')

                    # Add a tag
                    module = @
                    hitbox.mouseover (arg) =>
                        App.router.connectionsController.set 'hovered', @get('port')

                    hitbox.mouseout (arg) =>
                        App.router.connectionsController.set 'hovered', null

                    # # Raphael does not support the contextmenu event, so we do it the jQuery way
                    # $(b.node).bind('contextmenu', (event) =>
                    #     console.log "CTX", event
                    #     return false
                    # )

                    # Dragging
                    hitbox.node.draggable = true
                    hitbox.node.onDragStart = (event) =>
                        console.log "start"
                        App.router.connectionsController.startPairing @get('port')

                    hitbox.node.onDrag = (delta, event) =>
                        console.log "Move"

                    hitbox.node.onDragStop = =>
                        console.log "Up", @
                        App.router.connectionsController.completePairing()
                        App.router.selectionController.setSelection @get('port')

                    # Double click
                    hitbox.dblclick(=>
                        topic = @get('port.topic')
                        Ember.run.next(@, (->
                            resp = prompt("Enter a new topic name", topic);
                            return if resp == null

                            @set('port.topic', resp)
                        ))
                    )

                    @get('container').push box
                    @get('container').push @get('rettype_box')
                    @get('container').push hitbox

            )

        )
    )
)
