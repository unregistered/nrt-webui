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
        {{#each module in App.router.modulesController.content}}
            {{view view.Module moduleBinding="module"}}
        {{/each}}
        """)
        
        didInsertElement: ->
            el = @$()[0]
            console.log el[0]
            @paper = new Raphael(el, "100%", "100%")
        
        Module: Ember.View.extend(
            module: null
            paperBinding: "parentView.paper"
            template: Ember.Handlebars.compile("""
            <h2>Module</h2>
            {{module.moduid}}
            """)
            
            name: (->
                if Ember.empty @get('module.instance')
                    return @get('module.classname')
                
                return @get('module.instance')
            ).property('module.instance', 'module.classname')
            
            viewDidChange: (->
                console.log "View did change"
            ).observes('module.moduid')
            
            coordx: (->
                @get('module.coordinates')[0]
            ).property('module.coordinates')
            
            coordy: (->
                @get('module.coordinates')[1]
            ).property('module.coordinates')
            
            width: (->
                100
            ).property()
            
            height: (->
                150
            ).property()
            
            ###
            Components
            ###
            input_bubbles: (->
                coordx = @get('coordx')
                coordy = @get('coordy')
                width = @get('width')
                height = @get 'height'
                radius = 7 # Radius of each bubble
                
                initial_offset = 20 # How many pixels to offset the first bubble
                spacing = 8 # How many pixels to space each bubble after the first
                
                @get('module.subscribers').map (item, idx) =>
                    yoffset = initial_offset + idx * (radius * 2) + spacing * idx
                    bubble = @get('paper').circle(coordx, coordy + yoffset, radius)
                    
                    bubble.hover (arg) ->
                        console.log "hover", arg

                    return bubble
            ).property()
            
            output_bubbles: (->
                coordx = @get('coordx')
                coordy = @get('coordy')
                width = @get('width')
                height = @get 'height'
                radius = 7 # Radius of each bubble
                
                initial_offset = 20 # How many pixels to offset the first bubble
                spacing = 8 # How many pixels to space each bubble after the first
                
                @get('module.posters').map (item, idx) =>
                    yoffset = initial_offset + idx * (radius * 2) + spacing * idx
                    @get('paper').circle(coordx + width, coordy + yoffset, radius)
            ).property()
            
            
            box: (->
                # All the raphael objects together that should move as a group
                paper = @get('parentView').paper
                
                coordx = @get('coordx')
                coordy = @get('coordy')
                
                rect = paper.rect(coordx, coordy, @get('width'), @get('height'), 7)
                set = paper.set()
                set.push(rect)
                set.push(paper.text(coordx+50, coordy+50, @get('name')))
                
                for bubble in @get('input_bubbles')
                    set.push bubble
                
                for bubble in @get('output_bubbles')
                    set.push bubble
                    
                color = Raphael.getColor()
                rect.attr
                    fill: color
                    stroke: color
                    "fill-opacity": 0
                    "stroke-width": 2
                    cursor: "move"
                
                return set
            ).property()
            
            willDestroyElement: ->
                @set.remove()
                
            didInsertElement: ->
                box = @get('box')
                
                dragger = ->
                    box.oBB = box.getBBox()
                    @animate "fill-opacity": .2, 500

                move = (dx, dy) =>
                    bb = box.getBBox()
                    box.translate(box.oBB.x - bb.x + dx, box.oBB.y - bb.y + dy);
                    # update connections
                    # for connection in connections
                    #     r.connection connection
                    # r.safari()

                up = -> @animate "fill-opacity": 0, 500
                
                box.drag move, dragger, up
                box.mousedown ->
                    @.toFront()
                
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