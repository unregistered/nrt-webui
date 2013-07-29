"use strict"

###
Responsible for a couple things relating to connections:
* Registers the bounding box of ports to allow connectors to latch
* Assists active connections by providing a list of matching ports
###
angular.module('nrtWebuiApp').factory('ConnectorService', ($rootScope, ServerService, HoverService, ModuleManagerService) ->
    self = {};

    self.portdb = {} # Ports keyed by bbuid, moduid, portname
    self.registerPortBBox = (port, bbox) ->
        self.portdb["#{port.module.moduid}>>#{port.portname}"] = _.clone bbox

    self.getPortBBox = (port) ->
        self.portdb["#{port.module.moduid}>>#{port.portname}"]

    #
    # Pairing
    #
    self.pairFrom = null
    self.pairingState = 'IDLE'
    self.isPairing = ->
        self.pairingState == 'PAIRING'

    self.startPairing = (port) ->
        console.log "Begin pairing", port
        self.pairFrom = port
        self.pairingState = 'PAIRING'

        $rootScope.$broadcast("ConnectorService.pairing_state_changed")

    self.completePairing = ->
        # Get the hovered object
        connection = HoverService.getHovered 'connection'

        if connection
            if connection.from_port.orientation == 'poster'
                self.createConnection connection.from_port, connection.to_port
            else
                self.createConnection connection.to_port, connection.from_port

        self.pairFrom = null
        self.pairingState = 'IDLE'

        $rootScope.$broadcast("ConnectorService.pairing_state_changed")

    self.isViableCandidate = (port) ->
        return undefined unless self.pairFrom
        return false unless port

        # No, unless message types match
        return false unless self.pairFrom.msgtype == port.msgtype

        # No, unless orientations differ
        return false unless self.pairFrom.orientation != port.orientation # There's an insensitive joke in here

        # No, if a connection already exists
        # return false

        return true

    self.createConnection = (poster_port, subscriber_port) ->
        console.log "Create connection from poster to subscriber", poster_port, subscriber_port
        # If no source topic, then generate a random one
        topic = poster_port.topi
        if topic == ""
            topic = 'UnnamedTopic_' + Math.random().toString(36).substring(7)
            # Send message to loader to set poster topic
            ServerService.setPortTopic poster_port, topic

        filter = subscriber_port.topi
        if filter == ""
            filter = topic
        else
            filter += "|#{topic}"
        # Send message to loader to set checker/subscriber topic filter
        ServerService.setPortTopic subscriber_port, filter

    self.getPhantomConnections = ->
        return [] unless self.pairingState == 'PAIRING'

        viablePorts = _.filter ModuleManagerService.ports, (port) -> self.isViableCandidate(port)

        connections = _.map viablePorts, (port) ->
                    module = port.module
                    {
                        bbuid1: self.pairFrom.module.bbuid
                        module1: self.pairFrom.module.moduid
                        portname1: self.pairFrom.portname

                        from_module: self.pairFrom.module
                        from_port: self.pairFrom

                        bbuid2: module.bbuid
                        module2: module.moduid
                        portname2: port.portname

                        to_module: module
                        to_port: port
                    }

        return connections

    return self
)
