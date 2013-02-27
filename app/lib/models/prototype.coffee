require "nrt-webui/core"

App.Prototype = Ember.Object.extend(
    classname: null
    name: null
    description: null
    logicalPath: null
    blackboard: null

    init: ->
        logicalPath = @get 'from.logicalPath'
        @set 'logicalPath', logicalPath
        @set 'classname', logicalPath.split('/').pop()
        @set 'name', logicalPath.split('/').pop()
        @set 'description', "Desc"

)
