require "nrt-webui/core"

App.Connection = Ember.Object.extend(
    source_port: null
    destination_port: null

    source_moduleBinding: "source_port.module"
    destination_moduleBinding: "destination_port.module"

    init: ->
        if !(@get('source_port') && @get('destination_port'))
            source_mod = App.router.modulesController.findProperty('moduid', @get('from.module1'))
            destination_mod = App.router.modulesController.findProperty('moduid', @get('from.module2'))

            @set 'source_port', source_mod.get('posters').findProperty('portname', @get('from.portname1'))
            @set 'destination_port', destination_mod.get('subscribers').findProperty('portname', @get('from.portname2'))

            if !@get('destination_port')
                # We're probably a checker
                @set 'destination_port', destination_mod.get('checkers').findProperty('portname', @get('from.portname2'))
)
