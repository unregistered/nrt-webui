require "nrt-webui/core"

App.ServersController = Ember.ArrayController.extend(
    content: []
    selected: null
)

App.ServerController = Ember.Controller.extend(
    contentBinding: "App.router.serversController.selected"

    createModule: (prototype, x, y, bbnick) ->
        console.log "Create module at xy", x, y
        @get('content.session').call("org.nrtkit.designer/post/module",
            logicalPath: prototype.get('logicalPath'),
            bbNick: prototype.get('blackboard.bbnick')
        ).then( (res) =>
            console.log "Now set position"
            mod = App.Module.create(
                moduid: res
            )
            @updateModulePosition(mod, x, y)
        , (error, desc) =>
            console.log "Nope", error, desc
        )

    deleteModule: (module) ->
        console.log "Destroy module", module
        @get('content.session').call("org.nrtkit.designer/delete/module",
            moduid: module.get('moduid')
        ).then (res) =>
            console.log res
            App.router.modulesController.set('selected', null)

    updateModulePosition: (module, x, y) ->
        @get('content.session').call("org.nrtkit.designer/update/module_position",
            moduid: module.get('moduid')
            x: Math.round(x)
            y: Math.round(y)
        )

    setTopic: (port, topic) ->
        console.log "Set module topic"
        @get('content.session').call('org.nrtkit.designer/edit/module/topic',
            moduid: port.get('module.moduid')
            port_type: port.get('orientation')
            portname: port.get('portname')
            topi: topic
        ).then (res) =>
            console.log res

    createConnection: (from, to) ->
        console.log "Create connection on server"
        @setTopic(from, "Hello")
        @setTopic(to, "Hello")
        # @get('content.session').call("org.nrtkit.designer/post/connection",
        #     from_moduid: from.get('module.moduid'),
        #     from_portname: from.get('portname'),
        #     to_moduid: to.get('module.moduid'),
        #     to_portname: to.get('portname')
        # ).then (res) =>
        #     console.log res
)
