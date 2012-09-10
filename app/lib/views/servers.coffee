require "nrt-webui/core"

App.ServerView = Ember.View.extend(
    template: Ember.Handlebars.compile("""
    <div class="row-fluid">
        <div class="span4">
            {{view view.TrayView}}
        </div>
        <div class="span8">
            {{view view.WorkspaceView}}
        </div>
    </div>
    """)
    
    WorkspaceView: Ember.View.extend(
        classNames: ['workspace']
        
        template: Ember.Handlebars.compile("""
        {{view view.Connections}}
        {{view view.Modules}}
        """)
        
        didInsertElement: ->
            el = @$()[0]
            @set 'paper', new Raphael(el, "100%", "100%")
                    
        Connections: Ember.CollectionView.extend(
            contentBinding: "App.router.connectionsController.content"
            itemViewClass: Ember.View.extend(
                connectionBinding: "content"
                paperBinding: "parentView.paper"
                template: Ember.Handlebars.compile("connection")
            
                didInsertElement: ->
                    console.log "Connection", @get('connection')
                    # console.log @connection.get('source.coordx')
                    # path = [
                    #     "M"
                    #     @connection.get('source.coordx'), @connection.get('source.coordy')
                    #     "C"
                    #     # point2.x, point2.y
                    #     # point3.x, point3.y
                    #     @connection.get('destination.coordx'), @connection.get('destination.coordy')
                    # ].join ","
                    # console.log path
            )
        )
        
        Modules: Ember.CollectionView.extend(
            contentBinding: "App.router.modulesController.content"
            paperBinding: "parentView.paper"
            itemViewClass:  Ember.View.extend(
                moduleBinding: "content"
                paperBinding: "parentView.paper"
                template: Ember.Handlebars.compile("""
                <h2>Module: {{module.moduid}}</h2>
                <ul>
                {{#each view.input_params}}
                    {{view view.Bubble paramsBinding="this"}}
                {{/each}}
            
                {{#each view.output_params}}
                    {{view view.Bubble paramsBinding="this"}}
                {{/each}}
                </ul>
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
            
                ###
                Components
                ###
                input_params: (->
                    @get('module.subscribers').map (item, idx) ->
                        $.extend item, (
                            index: idx
                            orientation: 'input'
                        )
                ).property()
            
                output_params: (->
                    @get('module.posters').map (item, idx) ->
                        $.extend item, (
                            index: idx
                            orientation: 'output'
                        )
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
                ).property()
            
                container: (->
                    # All the objects that will be grouped into a Raphael set
                    console.log "Container?", @get('parentView.parentView.paper')
                    c = @get('paper').set()
                    console.log "Set?"
                    c.push @get('box')
                    c.push @get('text')
                    return c
                ).property()
            
                willDestroyElement: ->
                    @get('container').remove()
                
                beforeRender: ->
                    console.log "BEFORE RENDER"
                    module = @
                    container = @get('container')
                
                    dragger = =>
                        container.oBB = container.getBBox()
                        @get('box').animate "fill-opacity": .2, 500

                    move = (dx, dy) =>
                        bb = container.getBBox()
                        container.translate(container.oBB.x - bb.x + dx, container.oBB.y - bb.y + dy)
                        # update connections
                        # for connection in connections
                        #     r.connection connection
                        # r.safari()

                    up = =>
                        @get('box').animate "fill-opacity": 0, 500
                
                    container.drag move, dragger, up
                    container.mousedown ->
                        $.each module.get('container'), (idx, item) =>
                            item.toFront()
                
                didInsertElement: ->
                    # Move to location
                    x = @get('module.coordinates')[0]
                    y = @get('module.coordinates')[1]
                    @moveTo(x, y)
            
                moveTo: (x, y) ->
                    @get('container').translate(x, y)
            
                Bubble: Ember.View.extend(
                    template: Ember.Handlebars.compile("Bubble")
                    radius: 7 # Radius of each bubble
                    initial_offset: 20 # How many pixels to offset the first bubble
                    spacing: 8 # How many pixels to space each bubble after the first
                    containerBinding: 'parentView.container'
                    boxBinding: 'parentView.box'
                    paperBinding: 'parentView.paper'
                
                    coordx: (->
                        @get('circle').getBBox().x
                    ).property().volatile()
                
                    coordy: (->
                        @get('circle').getBBox().y
                    ).property().volatile()
                
                    circle:(->
                        xpos = @get('parentView.width') * (@get('params.orientation') is 'output')
                        ypos = @get('initial_offset') + @get('params.index') * (@get('radius') * 2) + @get('spacing') * @get('params.index')
                        @get('paper').circle(xpos, ypos, @get('radius'))
                    ).property()
                
                    label:(->
                        console.log @get('x')
                        t = @get('paper').text(@get('coordx')+20, @get('coordy'), @get('params.portname'))
                        t.attr (
                            'text-anchor': 'start'
                        )
                    ).property()
                
                    beforeRender: ->
                        c = @get('circle')
                    
                        # Add a tag
                        module = @
                        c.mouseover (arg) =>
                            console.log @get('label')
                            # module.get('paper').rect(this.attrs.cx + 20, this.attrs.cy, 100, 20)
                            @get('circle').attr({fill: 'green'})
                            console.log "hover", arg
                        c.mouseout (arg) =>
                            @get('circle').attr({fill: 'none'})
                            console.log "Mouseout"
                            @get('label').remove()
                            @notifyPropertyChange 'label'
                    
                        @get('container').push c
                    
                )
                
            )
        )
    )

    TrayView: Ember.View.extend(
        template: Ember.Handlebars.compile("""
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Modules</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <th>Module</th>
                </tr>
            </tbody>
        </table>
        """)
    )
)