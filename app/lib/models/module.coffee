require "nrt-webui/core"

App.Module = Ember.Object.extend(
    id: (->
        return @get('moduid')
    ).property('moduid')
    
    # bbuid: null
    # checkers: []
    dragging: false
    classname: null
    instance: null
    moduid: null
    # parameters: []
    # parent: null
    posters: []
    subscribers: []
    x: 0
    y: 0
    
    displayName: (->
        @get('classname')
    ).property('classname')
    
    selected: (->
        App.router.modulesController.get('selected') == @
    ).property("App.router.modulesController.selected")
    
    positionUpdater: (->
        if @get('dragging')
            App.router.serverController.publishModulePositionChange(@, @get('x'), @get('y'))
    ).observes('x', 'y')
    
    init: ->
        return unless @get('from')
        
        @set 'x', 0
        @set 'y', 0
        
        @set 'instance', @get 'from.instance'
        @set 'moduid', @get 'from.moduid'
        @set 'classname', @get 'from.classname'
                
        @set 'posters', @get('from.posters').map (item, idx) =>
            p = App.Port.create(item)
            p.reopen(
                index: idx
                orientation: 'output'
                module: this
            )
        
        @set 'subscribers', @get('from.subscribers').map (item, idx) =>
            p = App.Port.create(item)
            p.reopen(
                index: idx
                orientation: 'input'
                module: this
            )
)

App.Port = Ember.Object.extend(
    module: null
    description: null
    msgtype: null
    portname: null
    rettype: null
    topi: null
    
    id: (->
        @get('module.id') + "->" + @get('portname')
    ).property('module.id', 'portname')
    
)