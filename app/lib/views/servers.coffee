require "nrt-webui/core"

UI_PORT_RADIUS = 7
UI_PORT_INITIAL_OFFSET = 20
UI_PORT_SPACING = 8

App.ServerView = Ember.View.extend(
    template: Ember.Handlebars.compile("""
    <div class="row-fluid">
        <div class="span4">
            {{view App.TrayView}}
        </div>
        <div class="span8">
            {{view view.WorkspaceView}}
        </div>
    </div>
    """)
    
    WorkspaceView: Ember.View.extend(
        classNames: ['workspace']
        
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
                pan: true 
                drag: true
                zoomThreshold: [0.3, 2]
            })
            
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
                100
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
                    @get('module').setProperties (
                        x: Math.round(obb.x + delta.toX - delta.fromX)
                        y: Math.round(obb.y + delta.toY - delta.fromY)
                    )
                    
                box.node.onDragStop = =>
                    bb = container.getBBox()
                    @set 'module.x', Math.round(bb.x)
                    @set 'module.y', Math.round(bb.y)
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