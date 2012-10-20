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
                  <input type="text" class="input-medium search-query">
                  <button type="submit" class="btn">Search</button>
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
        {{view.prototype}}
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

# Shows a list of connected machines in the network
App.NetworkTrayView = Ember.View.extend(
    template: Ember.Handlebars.compile """
    Hello there
    """
)

# This is the actual tray view, which registers trays and displays them
App.TrayView = Ember.View.extend(
    controllerBinding: "App.router.prototypesController"
    traysAvailable: ["App.ModuleTrayView", "App.NetworkTrayView"]
    traysActive: null
    init: ->
        @_super()
        @set 'traysActive', Ember.Set.create()
    
    didInsertElement: ->
        @get('traysActive').add @get('traysAvailable.firstObject')
    
    template: Ember.Handlebars.compile("""
    <ul class="nav nav-pills">
        {{#each tray in view.traysAvailable}}
            {{view view.MenuItemView trayNameBinding="tray"}}
        {{/each}}
    </ul>
    
    {{view view.ListView}}
    """)
    
    toggleTray: (classname) ->
        if @traysActive.contains classname
            @traysActive.remove classname
        else
            @traysActive.add classname
    
    MenuItemView: Ember.View.extend(
        trayName: null
        tagName: 'li'
        template: Ember.Handlebars.compile """<a>{{view.trayName}}</a>"""
        
        classNameBindings: ['activeClass']
        classNames: ['pointable']
        activeClass: (->
            if @get('parentView.traysActive').contains @get('trayName')
                "active"
            else
                ""
        ).property('parentView.traysActive.[]')
        
        click: ->
            @get('parentView').toggleTray @get('trayName')
    )
    
    ListView: Ember.ContainerView.extend(
        # Transform the text list into view classes
        childViews: []
        
        shouldRerender: (->
            @get('childViews').clear()
            @get('parentView.traysActive').forEach (item) =>
                vc = Ember.get(item).create()
                @get('childViews').pushObject vc
        ).observes('parentView.traysActive.[]')
        
    )
)
