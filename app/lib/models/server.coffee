require "nrt-webui/core"

App.Server = Ember.Object.extend(
    name: ''
    host: ''
    port: 0
    
    modules: []
    
    wsuri: (->
        "ws://#{@get 'host'}:#{@get 'port'}"
    ).property('host', 'port')
    
    connect: ->
        # WAMP session was established
        ab.connect @get('wsuri'), ((session) =>
  
            # Get state
            session.call("org.nrtkit.designer/get/blackboard_federation_summary").then (res) =>
                console.log "Got ", res
                @set 'modules', res.message.namespaces[0].modules.map (item) =>
                    App.Module.create(item)
                @set 'connections', res.message.namespaces[0].connections.map (item) =>
                    source_params = item[0]
                    destination_params = item[1]
                    
                    source = @get('modules').findProperty('moduid', source_params.moduid)
                    destination = @get('modules').findProperty('moduid', destination_params.moduid)
                    App.Connection.create(
                        source: source
                        source_port: source_params.portname
                        destination: destination
                        destination_port: destination_params.portname
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