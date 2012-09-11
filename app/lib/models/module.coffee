require "nrt-webui/core"

App.Module = Ember.Object.extend(
    bbuid: null
    checkers: []
    classname: null
    instance: null
    moduid: null
    parameters: []
    parent: null
    posters: []
    subscribers: null
    x: 0
    y: 0
    
    init: ->
        @set 'x', @get('coordinates')[0]
        @set 'y', @get('coordinates')[1]
)
