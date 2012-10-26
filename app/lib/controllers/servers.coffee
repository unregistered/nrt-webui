require "nrt-webui/core"

App.ServersController = Ember.ArrayController.extend(
    content: []
    selected: null
)

App.ServerController = Ember.Controller.extend(
    contentBinding: "App.router.serversController.selected"
    
    createModule: (prototype, x, y) ->
        console.log @get('content')
        @get('content.session').call("org.nrtkit.designer/post/module", 
            classname: prototype.get('classname'),
            x: x,
            y: y
        ).then (res) =>
            console.log res
        
    deleteModule: (module) ->
        console.log "Destroy module", module
        @get('content.session').call("org.nrtkit.designer/delete/module",
            moduid: module.get('moduid')
        ).then (res) =>
            console.log res
        
    publishModulePositionChange: (module, x, y) ->
        @get('content.session').publish("org.nrtkit.designer/event/module_position_update",
            moduid: module.get('moduid')
            x: x
            y: y
        )
        console.log "Position updated"
)