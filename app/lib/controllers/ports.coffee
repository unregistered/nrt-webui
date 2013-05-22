require "nrt-webui/core"

App.PortsController = Ember.ArrayController.extend(
    modulesBinding: "App.router.modulesController.content"
    posters: (->
        a = []
        @get('modules') && @get('modules').forEach (mod) =>
            a.pushObjects mod.get('posters')
        return a
    ).property("modules.@each")

    subscribers: (->
        a = []
        @get('modules') && @get('modules').forEach (mod) =>
            a.pushObjects mod.get('subscribers')
        return a
    ).property("modules.@each")

    content: (->
        a = []
        a.pushObjects @get('posters')
        a.pushObjects @get('subscribers')
        return a
    ).property("posters", "subscribers")
)
