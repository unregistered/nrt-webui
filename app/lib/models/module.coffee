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

    # Width and height are set by the view
    width: 0
    height: 0

    displayName: (->
        @get('classname')
    ).property('classname')

    positionUpdater: (->
        if @get('dragging') && !@get('position_update_cooling_down')
            @set 'position_update_cooling_down', true

            # Only once every 100ms
            Ember.run.later(@, ->
                # This means the module update will be AT LEAST 100ms late
                App.router.serverController.updateModulePosition(@, @get('x'), @get('y'))
                @set 'position_update_cooling_down', false
            , 100)
    ).observes('x', 'y')

    init: ->
        return unless @get('from')

        @set 'instance', @get 'from.instance'
        @set 'moduid', @get 'from.moduid'
        @set 'classname', @get 'from.classname'
        @set 'bbuid', @get('from.bbuid')

        cached_coords = App.router.cacheController.get('content.module_position').get(@get('moduid'))
        if cached_coords
            @set 'x', cached_coords[0]
            @set 'y', cached_coords[1]
        else
            @set 'x', 0
            @set 'y', 0

        @set 'posters', @get('from.posters').map (item, idx) =>
            p = App.Port.create(from: item)
            p.reopen(
                index: idx
                orientation: 'output'
                module: this
            )

        @set 'subscribers', @get('from.subscribers').map (item, idx) =>
            p = App.Port.create(from: item)
            p.reopen(
                index: idx
                orientation: 'input'
                module: this
            )

        @set 'checkers', @get('from.checkers').map (item, idx) =>
            p = App.Port.create(from: item)
            p.reopen(
                index: idx
                orientation: 'checker'
                module: this
            )

)

App.Port = Ember.Object.extend(
    module: null
    orientation: null
    index: null

    description: null
    msgtype: null
    portname: null
    rettype: null
    topic: null

    id: (->
        @get('module.id') + "->" + @get('portname')
    ).property('module.id', 'portname')

    init: ->
        @set 'description', @get('from.description')
        @set 'msgtype', @get('from.msgtype')
        @set 'portname', @get('from.portname')
        @set 'rettype', @get('from.rettype')
        @set 'topic', @get('from.topi')

)
