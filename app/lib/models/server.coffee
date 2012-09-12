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
        ab.connect @get('wsuri'), ((session) =>
  
            # Get state
            session.call("org.nrtkit.designer/get/blackboard_federation_summary").then (res) =>
                console.log "Got ", res
                App.router.modulesController.set 'content', res.message.namespaces[0].modules.map (item) =>
                    App.Module.create(
                        from: item
                    )

                App.router.connectionsController.set 'content', res.message.namespaces[0].connections.map (item) =>
                    App.Connection.create(
                        from: item
                    )
                
            , (error, desc) =>
                console.log "Not got", error, desc
  
            # on event publication callback
            session.subscribe "org.nrtkit.designer/event/blackboard_federation_summary", (topic, event) =>
                console.log "got event1: ", event, @
                @set 'modules', event.message.namespaces[0].modules.map (item) =>
                    App.Module.create(item)
            
                

        # WAMP session is gone
        ), (code, reason) ->
            console.log reason
        
)