require "nrt-webui/core"

App.ServersController = Ember.ArrayController.extend(
    content: []
    selected: null
)

App.ServerController = Ember.Controller.extend(
    contentBinding: "App.router.serversController.selected"

    createModule: (prototype, x, y, bbnick) ->
        console.log "Create module at xy", x, y
        @get('content.session').call("org.nrtkit.designer/post/module",
            logicalPath: prototype.get('logicalPath'),
            bbNick: prototype.get('blackboard.bbnick')
        ).then( (res) =>
            console.log "Now set position"
            mod = App.Module.create(
                moduid: res
            )
            @updateModulePosition(mod, x, y)
        , (error, desc) =>
            console.log "Nope", error, desc
        )

    deleteModule: (module) ->
        console.log "Destroy module", module
        @get('content.session').call("org.nrtkit.designer/delete/module",
            moduid: module.get('moduid')
        ).then (res) =>
            console.log res
            App.router.modulesController.set('selected', null)

    updateModulePosition: (module, x, y) ->
        @get('content.session').call("org.nrtkit.designer/update/module_position",
            moduid: module.get('moduid')
            x: Math.round(x)
            y: Math.round(y)
        )

    setTopic: (port, topic) ->
        console.log "Set module topic"
        @get('content.session').call('org.nrtkit.designer/edit/module/topic',
            moduid: port.get('module.moduid')
            port_type: port.get('orientation')
            portname: port.get('portname')
            topi: topic
        ).then (res) =>
            console.log res

    createConnection: (from, to) ->
        console.log "Create connection on server"

        newTopic = from.get('module.moduid') + ':' + from.get('portname')
        newTopic = newTopic.replace(/\[|\]/g, '')

        topicMerge = (oldtopic, appendedtopic) ->
            base = ''

            # Append if there was already a topic
            if oldtopic
                console.log "There was an old topic"
                base += oldtopic

                # Make sure we aren't duplicating an existing topic
                isDuplicated = base.split('|').some (item) ->
                    item == appendedtopic

                if isDuplicated
                    console.log "Duplicated"
                else
                    base += "|" + appendedtopic
            else
                console.log "There was no old topic"
                base = appendedtopic

            return base

        fromNewTopic = topicMerge from.get('topic'), newTopic
        toNewTopic = topicMerge to.get('topic'), newTopic

        @setTopic(from, fromNewTopic)
        @setTopic(to, toNewTopic)

    deleteConnection: (connection) ->
        console.log "Remove connection"

        source = connection.get('source_port')
        source_topic = source.get('topic')

        destination = connection.get('destination_port')
        destination_topic = destination.get('topic')
        destination_topic_array = destination_topic.split('|')
        # Filter out the matching name
        destination_topic_array = destination_topic_array.filter (item) ->
            item != source_topic

        @setTopic(destination, destination_topic_array.join("|"))

        # Now the source topic. The source topic will only be removed if there are no
        # other destination ports requiring the topic.
        ports_exist_requiring_topic = App.router.connectionsController.get('content').some (c) ->
            return false if c == connection # Don't count ourself

            port = c.get('destination_port')

            topics = port.get('topic').split('|')
            return true if topics.contains source_topic

            return false

        # 1 because we've included ourself
        unless ports_exist_requiring_topic
            @setTopic(source, '')
)
