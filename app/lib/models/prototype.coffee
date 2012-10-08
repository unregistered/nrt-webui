require "nrt-webui/core"

App.Prototype = Ember.Object.extend(
    classname: null
    name: null
    description: null
    
    init: ->
        @set 'classname', @get 'from.classname'
        @set 'name', @get 'from.name'
        @set 'description', @get 'from.description'
            
)