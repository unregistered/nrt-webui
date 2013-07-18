"use strict"

###
Responsible for a couple things relating to connections:
* Registers the bounding box of ports to allow connectors to latch
* Assists active connections by providing a list of matching ports
###
angular.module('nrtWebuiApp').factory('ConnectorService', ($rootScope, ServerService) ->
    self = {};

    self.portdb = {} # Ports keyed by bbuid, moduid, portname
    self.registerPortBBox = (module, port, bbox) ->
        self.portdb["#{module.bbuid}>>#{module.moduid}>>#{port.portname}"] = bbox

    self.getPortBBox = (bbuid, moduid, portname) ->
        self.portdb["#{bbuid}>>#{moduid}>>#{portname}"]

    return self
)
