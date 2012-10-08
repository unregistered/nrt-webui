require "nrt-webui/core"


App.Router = Ember.Router.extend(
    enableLogging: true
  
    root: Ember.Route.extend(
        index: Ember.Route.extend(
            route: "/"
        )

        server: Ember.Route.extend(
            route: "/server/:host"
            deserialize: (router, params) ->
                return router.serversController.get('firstObject')

            serialize: (router, context) ->
                host = context.get 'host'
                port = context.get 'port'
                return host: "#{host}:#{port}"
                
            connectOutlets: (router, context) =>
                router.get('serversController').set 'selected', context
                router.get('applicationController').connectOutlet('server')
                context.connect()
        )
        
        viewServer: Ember.Route.transitionTo 'server'
    )
)