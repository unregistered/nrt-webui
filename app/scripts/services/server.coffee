"use strict"

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
                FederationSummaryParserService.updateFederationSummary res
                # $rootScope.$broadcast("ServerService.new_blackboard_federation_summary", res)
            , (error, desc) ->
                console.error "Failed to get blackboard_federation_summary", error, desc
            )

            # Subscribe to all further blackboard federation summaries 
            session.subscribe "org.nrtkit.designer/event/blackboard_federation_summary", (topic, message) ->
                $rootScope.$broadcast("ServerService.new_blackboard_federation_summary", message)

        , (error, desc) ->
            console.error "Failed to connect to (#{self.host}:#{self.port}) ", error, desc
        )

    self.requestLoaderSummary = (bbuid) ->
        prototypesPromise = $q.defer()

        self.session.call("org.nrtkit.designer/get/prototypes", bbuid).then((res) ->
            $rootScope.$apply -> prototypesPromise.resolve(res)
        , (error, desc) ->
            $rootScope.$apply -> prototypesPromise.reject(desc))

        return prototypesPromise.promise


    self.createModule = (prototype, x, y, bbuid) ->
        console.log "Create module", prototype.logicalPath, "at", x, y, "on", prototype.bbnick

    return self
)
