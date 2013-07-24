"use strict"

###
Parses and processes modules and ports
###
angular.module('nrtWebuiApp').factory('ModuleManagerService', ($rootScope, ServerService, FederationSummaryParserService, safeApply) ->
    self = {}

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}
    self.ports = []

    ######################################################################
    $rootScope.$on('ServerService.federation_update', (event, federation_summary) ->
        self.modules = federation_summary.modules
        self.ports = federation_summary.ports
    )

    ######################################################################
    self._modifyParameter = (parameter_update) ->
        console.log 'Modifying parameter ' + parameter_update.paramsummary.name, parameter_update
        module = self.modules[parameter_update.moduleuid]
        new_value = parameter_update.paramsummary.value
        descriptor = FederationSummaryParserService.stripParameterDescriptor parameter_update.paramsummary.descriptor

        parameter = _(module.parameters).findWhere({descriptor: descriptor})
        parameter.value = new_value

    ######################################################################
    self._destroyParameter = (parameter_update) ->
        module = self.modules[parameter_update.moduleuid]
        descriptor = FederationSummaryParserService.stripParameterDescriptor parameter_update.paramsummary.descriptor

        parameter = _(module.parameters).findWhere({descriptor: descriptor})

        if parameter
            module.parameters = _(module.parameters).reject (it) -> it.descriptor == descriptor
        else
            console.error 'Could not destroy unknown parameter', module, descriptor

    ######################################################################
    self._createParameter = (parameter_update) ->
        console.log 'Creating parameter ' + parameter_update.paramsummary.name,  parameter_update
        module = self.modules[parameter_update.moduleuid]
        summary = parameter_update.paramsummary

        parameter = FederationSummaryParserService.cleanParameter summary, module, summary.value

        return if _(module.parameters).findWhere {descriptor: parameter.descriptor}
        module.parameters.push parameter

    ######################################################################
    $rootScope.$on('ServerService.parameter_changed', (event, parameter_update) ->

        module = self.modules[parameter_update.moduleuid]
        new_value = parameter_update.paramsummary.value

        if parameter_update.paramsummary.state == 'Destroy'
            self._destroyParameter parameter_update
        else if parameter_update.paramsummary.state == 'Create'
            self._createParameter parameter_update
        else if parameter_update.paramsummary.state == 'Modify'
            self._modifyParameter parameter_update
        else
            console.error 'Unknown parameter update state: ', parameter_update.state

    )

    ######################################################################
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
