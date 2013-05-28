###
Static views
###

require "nrt-webui/core"

App.HomepageView = Ember.View.extend(
    hostname: null
    port: null

    templateName: "nrt-webui/~templates/homepage"

    setQuickConnect: ->
        console.log "Set QC"
        s = App.Server.create(
            name: 'QuickConnect'
            host: @get('hostname') || 'localhost'
            port: @get('port') || '8080'
        )

        App.router.send('quickConnect', s)
)
