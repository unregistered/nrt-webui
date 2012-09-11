require "nrt-webui/core"

App.ConnectionsController = Ember.ArrayController.extend(
    contentBinding: "App.router.serversController.selected.connections"
    
)