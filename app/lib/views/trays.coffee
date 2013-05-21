###
Contains tray views used in the main designer interface.
###
require "nrt-webui/core"

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
                    {{view App.TreeView}}
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
            <tbody>
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
                        </dl>
                    </td>
                </tr>

                <tr><td><a class="btn btn-danger" {{action deleteCurrentModule target="view"}}>Delete</a></td></tr>
            </tbody>
        {{/if}}

        {{#if view.modules}}
            <tbody>
                <tr><td class="h2">{{view.modules.length}} modules selected</td></tr>

                <tr><td><a class="btn btn-danger" {{action deleteSelectedModules target="view"}}>Delete Selected</a></td></tr>
            </tbody>
        {{/if}}

        {{#if view.empty}}
            <tbody>
                <tr>
                    <td>No module selected</td>
                </tr>
            </tbody>
        {{/if}}
    </table>
    """

    deleteSelectedModules: ->
        @get('modules').forEach (item) ->
            App.router.serverController.deleteModule item

    deleteCurrentModule: ->
        App.router.serverController.deleteModule @get('module')
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
    traysActive: null
    init: ->
        @_super()
        @set 'traysActive', Ember.Set.create()

    didInsertElement: ->
        @get('traysActive').add @get('traysAvailable.firstObject')

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

    ).observes("selectionController.content")

    toggleTray: (classname) ->
        # If allowing one
        @traysActive.clear()
        @traysActive.add classname

        # If allowing multiple
        ###
        if @traysActive.contains classname
            @traysActive.remove classname
        else
            @traysActive.add classname
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
            if @get('parentView.traysActive').contains @get('content')
                "active"
            else
                ""
        ).property('parentView.traysActive.[]')

        click: ->
            @get('parentView').toggleTray @get('content')
    )

    ListView: Ember.ContainerView.extend(
        # Transform the text list into view classes
        childViews: []

        shouldRerender: (->
            @get('childViews').clear()
            @get('parentView.traysActive').forEach (item) =>
                vc = Ember.get(item.get('class')).create()
                @get('childViews').pushObject vc
        ).observes('parentView.traysActive.[]')

    )
)
