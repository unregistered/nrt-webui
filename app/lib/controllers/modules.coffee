require "nrt-webui/core"

App.ModulesController = Ember.ArrayController.extend(
    contentBinding: "App.router.serversController.selected.modules"
)