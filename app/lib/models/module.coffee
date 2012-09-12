require "nrt-webui/core"

App.Module = Ember.Object.extend(
    id: (->
        return @get('moduid')
    ).property('moduid')
    
    # bbuid: null
    # checkers: []
    # classname: null
    instance: null
    moduid: null
    # parameters: []
    # parent: null
    posters: []
    subscribers: []
    x: 0
    y: 0
    
    init: ->
        @set 'x', @get('from.coordinates')[0]
        @set 'y', @get('from.coordinates')[1]
        
        @set 'instance', @get 'from.instance'
        @set 'moduid', @get 'from.moduid'
                
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