require "nrt-webui/core"


App.Router = Ember.Router.extend(
    enableLogging: true

    root: Ember.Route.extend(
        index: Ember.Route.extend(
            route: "/"

            connectOutlets: (router, context) ->
                router.get('applicationController').connectOutlet('homepage')

            quickConnect: (router, context) ->
                # Connect to the server in context
                router.transitionTo 'server', context
        )

        server: Ember.Route.extend(
            route: "/server/:host"
            deserialize: (router, params) ->
                host = params.host.split(':')[0]
                port = params.host.split(':')[1]

                s = router.serversController.get('content').filter (item) ->
                    item.get('host') == host && item.get('port') == port

                if s.get('length') == 0
                    # Nothing matching
                    return App.Server.create(
                        host: host
                        port: port
                        name: 'QuickConnect'
                    )

                return s.get('firstObject')

            serialize: (router, context) ->
                host = context.get 'host'
                port = context.get 'port'
                return host: "#{host}:#{port}"

            connectOutlets: (router, context) =>
                router.get('serversController').set 'selected', context
                router.get('applicationController').connectOutlet('server')
                router.get('namespaceController').set 'content', "/"
                context.connect()

            exit: (router) ->
                # Clear all state we've built up. Although ember normally takes care of this
                # for us, we have to do it manually since we're doing so much magic with
                # raphaeljs outside of the DOM that ember knows about.
                # Otherwise, errors will occur as views will try to update themselves
                # in the wrong order
                router.get('serversController').set 'selected', null
                router.set('modulesController.content', [])
                router.set('selectionController.content', [])
                router.set('portsController.content', [])
                router.set('connectionsController.content', [])

            goHome: Ember.Route.transitionTo 'index'

        )

        goHome: Ember.Route.transitionTo 'index'
        viewServer: Ember.Route.transitionTo 'server'
    )
)
