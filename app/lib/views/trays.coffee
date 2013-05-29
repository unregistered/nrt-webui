###
Contains tray views used in the main designer interface.
###
require "nrt-webui/core"

App.EditableText = Ember.View.extend(
    value: undefined
    temp: undefined
    is_editing: false
    template: Ember.Handlebars.compile """
    {{#if view.is_editing}}
        <div class="pull-left" style="margin-right: 10px">
            {{view Ember.TextField valueBinding="view.temp"}}
        </div>
        <div class="btn-group pull-left">
            <button class="btn btn-success" {{action finishEdit target="view"}}>Save</button>
            <button class="btn btn-success dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li><a {{action revertEdit target="view"}}>Cancel</a></li>
                <li><a {{action finishAndClear target="view"}}>Clear</a></li>
            </ul>
        </div>
        <div class="clearfix"></div>
    {{else}}
        {{#if view.value}}
            {{view.value}} <a {{action edit target="view"}}>Edit</a>
        {{else}}
            <a {{action edit target="view"}}>Set Value</a>
        {{/if}}
    {{/if}}
    """

    edit: (evt) ->
        @set 'temp', @get('value')
        @set 'is_editing', true

    finishEdit: (evt) ->
        @set 'value', @get('temp')
        @set 'is_editing', false

    finishAndClear: (evt) ->
        @set 'value', ''
        @set 'is_editing', false

    revertEdit: (evt) ->
        @set 'is_editing', false

)

# Shows a list of instantiatable modules
App.ModuleTrayView = Ember.View.extend(
    controllerBinding: "App.router.prototypesController"
    currentDirectory: '/'

    template: Ember.Handlebars.compile("""
    <table class="table table-bordered tray">
        <thead>
            <tr>
                <td class="h1">
                    Modules
                </td>
            </tr>
            <tr>
                <td>

                    <form class="form-search float-right" style="margin: 0">
                        {{view Ember.TextField
                        valueBinding="controller.filter"
                        class="input-medium search-query resizing"
                        placeholder="Filter"
                        }}
                    </form>

                </td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>
                    <div class="variable-height">
                        {{view App.TreeView}}
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
    """)

    filteredDirectories: (->
        dirs = []

        @get('controller.directories').forEach (item) ->
            dirs.pushObject item

        return dirs
    ).property('controller.directories.[]')

    filteredPrototypes: (->
        @get('controller.content').filter (item, idx) =>
            filter = @get('searchField')
            ~item.name.toLowerCase().indexOf(filter)

    ).property('controller.content.@each', 'searchField')
)

# Shows info about the currently selected module
App.CurrentSelectionTrayView = Ember.View.extend(
    selectionBinding: "App.router.selectionController.content"
    module: (->
        if @get('selection.length') == 1 && @get('selection.firstObject') instanceof App.Module
            return @get('selection.firstObject')
        else
            return null
    ).property("selection.@each")

    modules: (->
        # More than one module
        modules = @get('selection').filter (item) ->
            item instanceof App.Module

        if modules.get('length') > 1
            return modules
        else
            return null
    ).property("selection.@each")

    connection: (->
        if @get('selection.length') == 1 && @get('selection.firstObject') instanceof App.Connection
            return @get('selection.firstObject')
        else
            return null
    ).property("selection.@each")

    port: (->
        if @get('selection.length') == 1 && @get('selection.firstObject') instanceof App.Port
            return @get('selection.firstObject')
        else
            return null
    ).property('selection.@each')

    empty: (->
        return @get('selection.length') == 0
    ).property("selection.@each")

    template: Ember.Handlebars.compile """
    <table class="table table-bordered tray">
        <thead>
            <tr>
                <td class="h1">Info</td>
            </tr>
        </thead>

        {{#if view.module}}
            {{view view.ModuleView}}
        {{/if}}

        {{#if view.modules}}
            {{view view.ModulesView}}
        {{/if}}

        {{#if view.connection}}
            {{view view.ConnectionView}}
        {{/if}}

        {{#if view.port}}
            {{view view.PortView}}
        {{/if}}

        {{#if view.empty}}
            {{view view.NoSelectionView}}
        {{/if}}
    </table>
    """

    didInsertElement: ->


    PortView: Ember.View.extend(
        portBinding: 'parentView.port'
        tagName: 'tbody'
        template: Ember.Handlebars.compile """
        <tr><td class="h2">Port ({{view.port.orientation}})</td></tr>

        <tr>
            <td class="background">
                <dl>
                    <dt>Module</dt>
                    <dd>{{view.port.module.moduid}}</dd>
                    <dt>Port Name</dt>
                    <dd>{{view.port.portname}}</dd>
                    <dt>Message Type</dt>
                    <dd>{{view.port.msgtype}}</dd>
                    <dt>Return Type</dt>
                    <dd>{{view.port.rettype}}</dd>
                    <dt>Topic</dt>
                    <dd>{{view App.EditableText valueBinding="view.port.topic"}}</dd>
                    <dt>Description</dt>
                    <dd>{{view.port.description}}</dd>
                </dl>
            </td>
        </tr>
        """

        portTopicUpdater: (->
            App.router.serverController.setTopic @get('port'), @get('port.topic')
        ).observes('port.topic')
    )

    ModuleView: Ember.View.extend(
        moduleBinding: 'parentView.module'
        tagName: 'tbody'
        template: Ember.Handlebars.compile """
        <tr><td class="h2">{{view.module.instance}}</td></tr>
        <tr>
            <td class="background">
                <dl>
                    <dt>moduid</dt>
                    <dd>{{view.module.moduid}}</dd>
                    <dt>coordinates</dt>
                    <dd>({{view.module.x}}, {{view.module.y}})</dd>
                </dl>
            </td>
        </tr>

        <tr><td class="h2">Ports</td></tr>
        <tr>
            <td class="background">
                <div class="variable-height">
                    <dl>
                        {{#each view.module.posters}}
                            <dt>[poster] {{this.portname}} ({{this.msgtype}})</dt>
                            <dd>
                                {{this.description}}
                            </dd>
                        {{/each}}
                        {{#each view.module.subscribers}}
                            <dt>[subscriber] {{this.portname}} ({{this.msgtype}})</dt>
                            <dd>
                                {{this.description}}
                            </dd>
                        {{/each}}
                        {{#each view.module.checkers}}
                            <dt>[checker] {{this.portname}} ({{this.msgtype}})</dt>
                            <dd>
                                {{this.description}}
                            </dd>
                        {{/each}}
                    </dl>
                </div>
            </td>
        </tr>

        <tr><td><a class="btn btn-danger" {{action deleteCurrentModule target="view"}}>Delete</a></td></tr>
        """

        deleteCurrentModule: ->
            App.router.serverController.deleteModule @get('module')
    )

    ModulesView: Ember.View.extend(
        modulesBinding: 'parentView.modules'
        tagName: 'tbody'
        template: Ember.Handlebars.compile """
        <tr><td class="h2">{{view.modules.length}} modules selected</td></tr>

        <tr><td><a class="btn btn-danger" {{action deleteSelectedModules target="view"}}>Delete Selected</a></td></tr>
        """

        deleteSelectedModules: ->
            @get('modules').forEach (item) ->
                App.router.serverController.deleteModule item
    )

    ConnectionView: Ember.View.extend(
        connectionBinding: 'parentView.connection'
        tagName: 'tbody'
        template: Ember.Handlebars.compile """
        <tr><td class="h2">Connection</td></tr>

        <tr>
            <td class="background">
                <dl>
                    <dt>Source</dt>
                    <dd>{{view.connection.source_module.displayName}} : {{view.connection.source_port.portname}}</dd>
                    <dt>Destination</dt>
                    <dd>{{view.connection.destination_module.displayName}} : {{view.connection.destination_port.portname}}</dd>
                </dl>
            </td>
        </tr>

        <tr><td><a class="btn btn-danger" {{action deleteConnection target="view"}}>Delete Connection</a></td></tr>
        """

        deleteConnection: ->
            App.router.serverController.deleteConnection @get('connection')
    )

    NoSelectionView: Ember.View.extend(
        tagName: 'tbody'
        template: Ember.Handlebars.compile """
        <tr>
            <td>Selection is empty</td>
        </tr>
        """
    )
)

# Shows a list of connected machines in the network
App.NetworkTrayView = Ember.View.extend(
    template: Ember.Handlebars.compile """
    <table class="table table-bordered tray">
        <thead>
            <tr>
                <td class="h1">Network</td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <th>localhost <i class="icon-ok-sign"></i></th>
            </tr>
        </tbody>
    </table>
    """
)

# This is the actual tray view, which registers trays and displays them
App.TrayView = Ember.View.extend(
    selectionControllerBinding: "App.router.selectionController"
    traysAvailable: [
        Ember.Object.create(
            class: "App.ModuleTrayView"
            icon: "icon-plus"
        ),
        Ember.Object.create(
            class: "App.CurrentSelectionTrayView"
            icon: "icon-info-sign"
        ),
        Ember.Object.create(
            class: "App.NetworkTrayView"
            icon: "icon-globe"
        )

    ]
    activeTray: null

    variableHeightPaneObserver: (->
        return unless @$()
        el = @$().find('.variable-height')
        return if Ember.empty el

        parent = el.closest('.tray')

        # Check if the tray is overflowing
        totalHeight = parent.height() + parent.offset().top
        if totalHeight > Window.get('height')
            # We are over
            # Find how much we should cut down
            idealSavings = totalHeight - Window.get('height') + 20
            newHeight = el.height() - idealSavings
            newHeight = 20 if newHeight < 20 # The min height
            el.height(newHeight)

    ).observes('Window.height', 'Window.width')

    repeatingHeightPaneObserver: (->
        @variableHeightPaneObserver()
        Ember.run.later(@, (->
            @repeatingHeightPaneObserver()
        ), 1000)
    ).observes('activeTray')

    didInsertElement: ->
        @repeatingHeightPaneObserver()
        @set 'activeTray', @get('traysAvailable.firstObject')

    template: Ember.Handlebars.compile("""
    <ul class="nav nav-pills">
        {{#each tray in view.traysAvailable}}
            {{view view.MenuItemView contentBinding="tray"}}
        {{/each}}
    </ul>

    {{view view.ListView}}
    """)

    # Automatically toggle trays based on selection
    trayHelper: (->
        selection = @get('selectionController.content')

        classname = "App.ModuleTrayView"
        if selection.get('length') == 0
            classname = "App.ModuleTrayView"
        else
            classname = "App.CurrentSelectionTrayView"

        tray = @traysAvailable.findProperty("class", classname)
        @toggleTray(tray)

    ).observes("selectionController.content.@each")

    toggleTray: (trayobj) ->
        # If allowing one
        @set 'activeTray', trayobj

        # If allowing multiple
        ###
        if @traysActive.contains trayobj
            @traysActive.remove trayobj
        else
            @traysActive.add trayobj
        ###

    MenuItemView: Ember.View.extend(
        content: null
        tagName: 'li'
        template: Ember.Handlebars.compile """
        <a><i {{bindAttr class="view.iconClass"}}></i></a>
        """

        iconClass: (->
            @get('content.icon')
        ).property('content.icon')


        classNameBindings: ['activeClass']
        classNames: ['pointable']
        activeClass: (->
            if @get('parentView.activeTray') == @get('content')
                "active"
            else
                ""
        ).property('parentView.activeTray')

        click: ->
            @get('parentView').toggleTray @get('content')
    )

    ListView: Ember.ContainerView.extend(
        # Transform the text list into view classes
        childViews: []

        shouldRerender: (->
            @get('childViews').clear()
            vc = Ember.get(@get('parentView.activeTray').get('class')).create()
            @get('childViews').pushObject vc
        ).observes('parentView.activeTray')

    )
)
