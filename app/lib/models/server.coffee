require "nrt-webui/core"

App.Server = Ember.Object.extend(
    name: ''
    host: ''
    port: 0

    connected: false

    modulesBinding: "App.router.modulesController.content"
    blackboardsBinding: "App.router.blackboardsController.content"
    connectionsBinding: "App.router.connectionsController.content"

    wsuri: (->
        "ws://#{@get 'host'}:#{@get 'port'}"
    ).property('host', 'port')

    connect: ->
        # WAMP session was established
        # ab.debug(true, true)
        ab.connect @get('wsuri'), ((session) =>
            @set 'session', session
            @set 'connected', true

            # Get state
            session.call("org.nrtkit.designer/get/blackboard_federation_summary").then (res) =>
                @deserialize_bbfs(res)

                App.router.blackboardsController.content.forEach (blackboard) =>
                    session.call("org.nrtkit.designer/get/prototypes", blackboard.get('bbnick')).then (res) =>
                        prototypes = res.message.modules.map (item) =>
                            App.Prototype.create(from: item, blackboard: blackboard)

                        console.log res
                        App.router.prototypesController.get('content').pushObjects prototypes
                , (error, desc) =>
                    console.log "Not got", error, desc

            , (error, desc) =>
                console.log "Not got", error, desc

            # Get GUI coords
            session.call("org.nrtkit.designer/get/gui_data").then (res) =>
                console.log "Got GUI Data"
                @deserialize_gui_data(res)
            , (error, desc) =>
                console.log "Not got", error, desc

            # on event publication callback
            session.subscribe "org.nrtkit.designer/event/blackboard_federation_summary", (topic, event) =>
                @deserialize_bbfs(event)

            session.subscribe "org.nrtkit.designer/event/gui_data_update", (topic, event) =>
                @deserialize_gui_data(event)

        # WAMP session is gone
        ), (code, reason) =>
            console.log "WAMP Session ended"
            @set 'connected', false
            @set 'disconnection_reason', reason
            console.log reason

    deserialize_gui_data: (res) ->
        for item in res.message
            if item.id.substring(0, 2) == "m:"
                module = App.router.modulesController.findProperty('moduid', item.id.substring(2, item.id.length))
                if module
                    module.set 'x', item.x
                    module.set 'y', item.y
                    App.router.cacheController.get('content.module_position').set module.get('moduid'), [item.x, item.y]
                else
                    console.log "Not found:", item

    deserialize_bbfs: (res) ->
        App.router.blackboardsController.set 'content', res.message.bbnicks.map (item) =>
            App.Blackboard.create(
                from: item
            )

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
