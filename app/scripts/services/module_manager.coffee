"use strict"

###
Parses and processes modules and ports
###
angular.module('nrtWebuiApp').factory('ModuleManagerService', ($rootScope, ServerService, safeApply) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}
    self.ports = []

    $rootScope.$on('ServerService.federation_update', (event, federation_summary) ->
        self.modules = federation_summary.modules
        self.ports = federation_summary.ports
    )

    $rootScope.$on('ServerService.module_position_update', (event, positions) ->
        _(positions).each (position) ->
            moduid = position.id.substring(2) # Knock off prefix m: or n:
            module = self.modules[moduid]
            return unless module
            module.x = position.x
            module.y = position.y
            # if module.x != 0 && module.y != 0
            #     console.log "Module", module, "is not 0"

        safeApply($rootScope)
    )

    return self
)
