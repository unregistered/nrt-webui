require "nrt-webui/core"

App.Prototype = Ember.Object.extend(
    classname: null
    name: null
    description: null
    
    init: ->
        @set 'classname', "Classname"
        @set 'name', @get 'from.logicalPath'
        @set 'description', "Desc"
            
)