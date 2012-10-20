require "nrt-webui/core"

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
        {{#each App.router.connectionsController.content}}
            {{view view.Connection connectionBinding="this"}}
        {{/each}}
        {{#each App.router.modulesController.content}}
            {{view view.Module moduleBinding="this"}}
        {{/each}}
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
        
        Connection: Ember.RaphaelView.extend(
            template: Ember.Handlebars.compile("connection")
                        
            onUpdate: (->
                @get('paper').connection @get('line')
            ).observes('connection.source_module.x', 'connection.source_module.y', 'connection.destination_module.x', 'connection.destination_module.y')
            
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
                if Ember.empty @get('module.instance')
                    return @get('module.classname')
                
                return @get('module.instance')
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
                150
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
                c.push @get('box')
                c.push @get('text')
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
                    @get('box').animate "fill-opacity": .2, 500

                box.node.onDrag = (delta, event) =>
                    obb = container.oBB
                    @get('module').setProperties (
                        x: obb.x + delta.toX - delta.fromX
                        y: obb.y + delta.toY - delta.fromY
                    )

                box.node.onDragStop = =>
                    bb = container.getBBox()
                    @set 'module.x', bb.x
                    @set 'module.y', bb.y
                    @set 'module.dragging', false
                    @get('box').animate "fill-opacity": 0, 500
                
                # container.drag move, dragger, up
                container.mousedown ->
                    $.each module.get('container'), (idx, item) =>
                        item.toFront()
                            
            move: (->
                m = @get('module')
                @moveTo(m.get('x'), m.get('y'))
            ).observes('module.x', 'module.y')
            
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
                """)
                radius: 7 # Radius of each bubble
                initial_offset: 20 # How many pixels to offset the first bubble
                spacing: 8 # How many pixels to space each bubble after the first
                containerBinding: 'parentView.container'
                boxBinding: 'parentView.box'
                elementIdBinding: "port.id"
                
                coordx: (->
                    @get('circle').getBBox().x
                ).property().volatile()
                
                coordy: (->
                    @get('circle').getBBox().y
                ).property().volatile()
                
                circle:(->
                    xpos = @get('parentView.width') * (@get('port.orientation') is 'output')
                    ypos = @get('initial_offset') + @get('port.index') * (@get('radius') * 2) + @get('spacing') * @get('port.index')
                    circle = @get('paper').circle(xpos, ypos, @get('radius'))
                    circle.node.draggable = false
                    return circle
                ).property()
                
                label:(->
                    t = @get('paper').text(@get('coordx')+20, @get('coordy'), @get('port.portname'))
                    t.attr (
                        'text-anchor': 'start'
                    )
                ).property()
                
                beforeRender: ->
                    c = @get('circle')
                    
                    # Add a tag
                    module = @
                    c.mouseover (arg) =>
                        # module.get('paper').rect(@get('coordx') + 20, @get('coordy'), 100, 20)
                        @get('label')
                        @get('circle').attr({fill: 'green'})
                    c.mouseout (arg) =>
                        @get('circle').attr({fill: 'none'})
                        @get('label').remove()
                        @notifyPropertyChange 'label'
                    
                    # Dragging
                    dragger = =>
                        console.log "start"

                    move = (dx, dy) =>
                        console.log "Move"               

                    up = =>
                        console.log "Up"
                
                    c.drag move, dragger, up
                    
                    @get('container').push c
                    
            )
                
        )
    )
)