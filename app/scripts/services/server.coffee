"use strict"

###
Interacts with the server
@broadcasts ServerService.federation_update containing the parsed federation
@broadcasts ServerService.module_position_update containing array of moduids and positions
###
angular.module('nrtWebuiApp').factory('ServerService', ($timeout, $rootScope, $q, FederationSummaryParserService, AlertRegistryService, safeApply) ->
    self = {}

    self.name = ''
    self.host = ''
    self.port = ''
    self.connected = false

    self.last_update_time = NaN

    ######################################################################
    self.getWsUri = ->
        "ws://#{self.host}:#{self.port}"

    ######################################################################
    self.connect = ->
        console.log "Connecting to #{self.host}:#{self.port}"
        ab.connect(self.getWsUri(), (session) ->
            self.session   = session
            self.connected = true

            # Get the latest blackboard federation summary
            session.call("org.nrtkit.designer/get/blackboard_federation_summary").then((res) ->
                try
                    federation = FederationSummaryParserService.parseFederationSummary res
                    $rootScope.$broadcast("ServerService.federation_update", federation)

                catch error
                    console.error error.message
                    console.error error.stack
            , (error, desc) ->
                console.error "Failed to get blackboard_federation_summary", error, desc
            )

            # Get the latest gui coords
            # Timeout hack is to get ports to render in the correct location
            $timeout(->
                session.call("org.nrtkit.designer/get/gui_data").then (res) ->
                    $rootScope.$broadcast("ServerService.module_position_update", res.message)
                , (error, desc) ->
                    console.error "Not got", error, desc
            , 100)

            # Subscribe to all further blackboard federation summaries
            session.subscribe "org.nrtkit.designer/event/blackboard_federation_summary", (topic, message) ->
                try
                    self.federation = FederationSummaryParserService.parseFederationSummary message
                    $rootScope.$broadcast("ServerService.federation_update", self.federation)
                catch error
                    console.error error.message
                    console.error error.stack

            # Subscribe to all further blackboard federation summaries
            session.subscribe "org.nrtkit.designer/event/module_param_update", (topic, message) ->
                try
                    $rootScope.$broadcast "ServerService.parameter_changed", message.message
                catch error
                    console.error error.message
                    console.error error.stack

            # Subscribe to all further gui coordinate messages
            session.subscribe "org.nrtkit.designer/event/gui_data_update", (topic, res) ->
                $rootScope.$broadcast("ServerService.module_position_update", res.message)
            , (error, desc) ->
                console.error "Did not get gui data event", error, desc

        , (error, desc) ->
            console.error "Failed to connect to (#{self.host}:#{self.port}) ", error, desc
            AlertRegistryService.registerError "Failed to connect to #{self.host}:#{self.port}", "Reason: #{desc}", true
        ,
            # WAMP Session options
            maxRetries: 0
        )

    ######################################################################
    self.requestLoaderSummary = (bbuid) ->
        prototypesPromise = $q.defer()

        unless bbuid
            console.error 'Cannot request loader summary from', bbuid
            return null

        self.session.call("org.nrtkit.designer/get/prototypes", bbuid).then((res) ->
            $rootScope.$apply -> prototypesPromise.resolve(res)
        , (error, desc) ->
            $rootScope.$apply -> prototypesPromise.reject(desc))

        return prototypesPromise.promise

    ######################################################################
    self.setParameter = (module, parameter, new_value) ->
        resultPromise = $q.defer()

        message =
            parameter_descriptor: parameter.descriptor
            parameter_value: String(new_value)
            module_uid: module.moduid

        self.session.call("org.nrtkit.designer/edit/parameter", message).then((res) ->
            $rootScope.$apply -> resultPromise.resolve(res)
        , (error) ->
            $rootScope.$apply -> resultPromise.reject(error)

        )

        return resultPromise.promise

    ######################################################################
    self.getParameter = (module, parameter) ->
        resultPromise = $q.defer()

        message =
            parameter_descriptor: parameter.descriptor
            module_uid: module.moduid

        self.session.call("org.nrtkit.designer/get/parameter", message).then((res) ->
            $rootScope.$apply -> resultPromise.resolve(res)
            #parameter.value = res
        , (error) ->
            $rootScope.$apply -> resultPromise.reject(error)
        )

        return resultPromise.promise


    ######################################################################
    self.createModule = (prototype, x, y) ->
        console.log "Create module", prototype.logicalPath, "at", x, y, "on", prototype.blackboard.nick, prototype
        message =
            bbNick: prototype.blackboard.nick
            logicalPath: prototype.logicalPath

        self.session.call("org.nrtkit.designer/post/module", message).then((moduid) ->
            move_message =
                moduid: moduid
                x: Math.round(x)
                y: Math.round(y)
            self.session.call("org.nrtkit.designer/update/module_position", move_message)

        , (error, desc) ->
            console.error 'Failed to create module', desc
        )

    self.updateModulePosition = (module, x, y) ->
        self.session.call("org.nrtkit.designer/update/module_position",
            moduid: module.moduid
            x: Math.round(x)
            y: Math.round(y)
        )

    self.deleteModule = (module) ->
        self.session.call("org.nrtkit.designer/delete/module",
            moduid: module.moduid
        ).then( (res) ->
            console.log res
        , (error, desc) ->
            console.error error, desc
        )

    ######################################################################
    self.setPortTopic = (port, topic) ->
        console.log "Set module topic", port, topic
        self.session.call('org.nrtkit.designer/edit/module/topic',
            moduid: port.module.moduid
            port_type: port.orientation
            portname: port.portname
            topi: topic
        ).then (res) =>
            console.log res


    return self
)
