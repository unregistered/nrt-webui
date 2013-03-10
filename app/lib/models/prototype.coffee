require "nrt-webui/core"

App.Prototype = Ember.Object.extend(
    classname: null
    name: null
    description: null
    logicalPath: null
    blackboard: null # Must be set during creation
    icondata: null
    iconext: null

    readableName: (->
        name = @get('name')
        name.replace(/([a-z])([A-Z])/g, '$1 $2')
    ).property('name')

    MIME: (->
        ext = @get('iconext')
        if ext == '.png'
            return 'image/png'
        else if ext == '.jpg' or ext == '.jpeg'
            return 'image/jpeg'
        else
            return null

    ).property('iconext')

    init: ->
        logicalPath = @get 'from.logicalPath'
        @set 'logicalPath', logicalPath
        @set 'classname', logicalPath.split('/').pop()
        @set 'name', logicalPath.split('/').pop()
        @set 'description', "Desc"

        @set 'iconext', @get('from.iconext')
        @set 'icondata', @get('from.icondata')

)
