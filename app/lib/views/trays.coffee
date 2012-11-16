###
Contains tray views used in the main designer interface.
###
require "nrt-webui/core"

# Shows a list of instantiatable modules
App.ModuleTrayView = Ember.View.extend(
    template: Ember.Handlebars.compile("""
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>
                <form class="form-search">
                  <input type="text" class="input-medium search-query" placeholder="Filter">
                </form>
                </th>
            </tr>
        </thead>
        <tbody>
            {{#each controller.content}}
            <tr>
                {{view view.PrototypeView prototypeBinding="this"}}
            </tr>
            {{/each}}
        </tbody>
    </table>
    """)
    
    PrototypeView: Ember.View.extend(
        tagName: 'td'
        classNames: ["module-prototype"]
        template: Ember.Handlebars.compile("""
        Module: {{view.prototype.name}}
        """)
            
        didInsertElement: ->
            prototype = @get('prototype')

            @.$().draggable(
                opacity: 0.7
                cursor: "crosshair"
                cursorAt: { top: 5, left: 0 }
                helper: (event) ->
                  return $("<span class='ui-widget-helper'>New '#{prototype.name}'</span>")
                revert: "invalid"
                start: (event, ui) ->
                    $(this).data('context', prototype)
            )
            
    )
    
)

# Shows info about the currently selected module
App.CurrentModuleTrayView = Ember.View.extend(
    moduleBinding: "App.router.modulesController.selected"
    template: Ember.Handlebars.compile """
    <table class="table table-bordered">
        <thead>
            <tr>
                <td>{{view.title}}</td>
            </tr>
        </thead>
        {{#if view.module}}
            <tbody>
                <tr><td>Basic Info</td></tr>
                <tr>
                    <td>
                        <dl>
                            <dt>moduid</dt>
                            <dd>{{view.module.moduid}}</dd>
                            <dt>coordinates</dt>
                            <dd>({{view.module.x}}, {{view.module.y}})</dd>
                        </dl>
                    </td>
                </tr>
            
                <tr><td>Ports</td></tr>
                <tr>
                    <td>
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
    </table>
    """
    
    title: (->
        @get('module.instance') || "No Module Selected"
    ).property('module.instance')
    
    deleteCurrentModule: ->
        App.router.serverController.deleteModule @get('module')
)

# Shows a list of connected machines in the network
App.NetworkTrayView = Ember.View.extend(
    template: Ember.Handlebars.compile """
    <table class="table table-bordered">
        <thead>
            <tr>
                <td>Network</td>
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
    controllerBinding: "App.router.prototypesController"
    traysAvailable: [
        Ember.Object.create(
            class: "App.NetworkTrayView"
            icon: "icon-globe"
        ),
        Ember.Object.create(
            class: "App.ModuleTrayView"
            icon: "icon-plus"
        ), 
        Ember.Object.create(
            class: "App.CurrentModuleTrayView"
            icon: "icon-info-sign"
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
