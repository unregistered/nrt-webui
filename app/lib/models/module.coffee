require "nrt-webui/core"

App.Module = Ember.Object.extend(
    id: (->
        return @get('moduid')
    ).property('moduid')

    blackboard: (->
        App.router.blackboardsController.content.findProperty('id', @get('bbuid'))
    ).property('bbuid')

    dragging: false
    classname: null
    instance: null
    moduid: null
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
        if @get('dragging') && !@get('position_update_cooling_down')
            App.router.serverController.updateModulePosition(@, @get('x'), @get('y'))
            @set 'position_update_cooling_down', true

            # Only once every 100ms
            Ember.run.later(@, ->
                @set 'position_update_cooling_down', false
            , 100)
    ).observes('x', 'y')

    init: ->
        return unless @get('from')

        @set 'x', 0
        @set 'y', 0

        @set 'instance', @get 'from.instance'
        @set 'moduid', @get 'from.moduid'
        @set 'classname', @get 'from.classname'
        @set 'bbuid', @get('from.bbuid')

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
