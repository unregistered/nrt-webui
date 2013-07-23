"use strict"

###
Parses and processes modules and ports
###
angular.module('nrtWebuiApp').factory('ModuleManagerService', ($rootScope, ServerService, FederationSummaryParserService) ->
    self = {}

    self.updateParameter = (moduid, parameter) ->
        console.log 'Update parameter ', moduid, parameter


    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}
    self.ports = []

    $rootScope.$on('ServerService.federation_update', (event, federation_summary) ->
        self.modules = federation_summary.modules
        self.ports = federation_summary.ports
    )

    $rootScope.$on('ServerService.parameter_changed', (event, parameter_update) ->

        module = self.modules[parameter_update.moduleuid]
        descriptor = FederationSummaryParserService.stripParameterDescriptor parameter_update.paramsummary.descriptor
        new_value = parameter_update.paramsummary.value

        parameter = _(module.parameters).findWhere({descriptor: descriptor})
        console.log 'XXXXXXXXXXX', module.parameters, descriptor, parameter
        parameter.value = new_value
    )

    $rootScope.$on('ServerService.module_position_update', (event, positions) ->
        _(positions).each (position) ->
            moduid = position.id.substring(2) # Knock off prefix m: or n:
            module = self.modules[moduid]
            return unless module
            module.x = position.x
            module.y = position.y
    )

    return self
)
