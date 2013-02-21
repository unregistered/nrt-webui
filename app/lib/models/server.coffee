require "nrt-webui/core"

App.Server = Ember.Object.extend(
    name: ''
    host: ''
    port: 0
    
    modulesBinding: "App.router.modulesController.content"
    connectionsBinding: "App.router.connectionsController.content"
    
    wsuri: (->
        "ws://#{@get 'host'}:#{@get 'port'}"
    ).property('host', 'port')
    
    connect: ->
        # WAMP session was established
        ab.debug(true, true)
        ab.connect @get('wsuri'), ((session) =>
            @set 'session', session
  
            # Get state
            session.call("org.nrtkit.designer/get/blackboard_federation_summary").then (res) =>
                console.log "Got ", res
                @deserialize_bbfs(res)
            , (error, desc) =>
                console.log "Not got", error, desc

            # Get GUI coords
            session.call("org.nrtkit.designer/get/gui_data").then (res) =>
                @deserialize_gui_data(res)                
            , (error, desc) =>
                console.log "Not got", error, desc

            # Get Prototypes
            session.call("org.nrtkit.designer/get/prototypes", "ubuntu1204").then (res) =>
                console.log "Got ", res
                App.router.prototypesController.set 'content', res.message.modules.map (item) =>
                    App.Prototype.create(from: item)
                    
            , (error, desc) =>
                console.log "Not got", error, desc
  
            # on event publication callback
            session.subscribe "org.nrtkit.designer/event/blackboard_federation_summary", (topic, event) =>
                console.log "got event1: ", event
                @deserialize_bbfs(event)
                        
            session.subscribe "org.nrtkit.designer/event/gui_data_update", (topic, event) =>
                console.log "Module position updated", event
                @deserialize_gui_data(event)
                    
        # WAMP session is gone
        ), (code, reason) ->
            console.log reason
    
    deserialize_gui_data: (res) ->
        for item in res.message
            if item.id.substring(0, 2) == "m:"
                module = App.router.modulesController.findProperty('moduid', item.id.substring(2, item.id.length))
                if module
                    module.set 'x', item.x
                    module.set 'y', item.y
                else
                    console.log "Not found:", item
        
    deserialize_bbfs: (res) ->
        App.router.modulesController.set 'content', res.message.namespaces[0].modules.map (item) =>
            App.Module.create(
                from: item
            )

        App.router.connectionsController.set 'content', res.message.namespaces[0].connections.map( (item) =>
            c = App.Connection.create(
                from: item
            )
        ).filter( (item) =>
            # Ignore bad connections
            item.get('source_port') && item.get('destination_port')
        )
            
        # App.router.prototypesController.set 'content', res.message.namespaces[0].prototypes.map (item) =>
        #     App.Prototype.create(
        #         from: item
        #     )
        
)