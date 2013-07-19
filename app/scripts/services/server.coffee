"use strict"

###
Interacts with the server
@broadcasts ServerService.federation_update containing the parsed federation
@broadcasts ServerService.module_position_update containing array of moduids and positions
###
angular.module('nrtWebuiApp').factory('ServerService', ($timeout, $rootScope, $q, FederationSummaryParserService) ->
    self = {}

    self.name = ''
    self.host = ''
    self.port = ''
    self.connected = false

    self.last_update_time = NaN

    self.getWsUri = ->
        "ws://#{self.host}:#{self.port}"

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
            session.call("org.nrtkit.designer/get/gui_data").then (res) =>
                $rootScope.$broadcast("ServerService.module_position_update", res.message)
            , (error, desc) =>
                console.log "Not got", error, desc

            # Subscribe to all further blackboard federation summaries
            session.subscribe "org.nrtkit.designer/event/blackboard_federation_summary", (topic, message) ->
                try
                    FederationSummaryParserService.parseFederationSummary message
                catch error
                    console.error error.message
                    console.error error.stack

        , (error, desc) ->
            console.error "Failed to connect to (#{self.host}:#{self.port}) ", error, desc
        )

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


    self.createModule = (prototype, x, y, bbuid) ->
        console.log "Create module", prototype.logicalPath, "at", x, y, "on", prototype.bbnick

    return self
)
