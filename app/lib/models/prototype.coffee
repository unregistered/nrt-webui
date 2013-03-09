require "nrt-webui/core"

App.Prototype = Ember.Object.extend(
    classname: null
    name: null
    description: null
    logicalPath: null
    blackboard: null

    readableName: (->
        name = @get('name')
        name.replace(/([a-z])([A-Z])/g, '$1 $2')
    ).property('name')

    init: ->
        logicalPath = @get 'from.logicalPath'
        @set 'logicalPath', logicalPath
        @set 'classname', logicalPath.split('/').pop()
        @set 'name', logicalPath.split('/').pop()
        @set 'description', "Desc"

)
