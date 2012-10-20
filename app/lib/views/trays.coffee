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
        template: Ember.Handlebars.compile("""
        {{view.prototype}}
        """)
            
        didInsertElement: ->
            prototype = @get('prototype')

            @.$().draggable(
                opacity: 0.7
                cursorAt: { top: -12, left: -20 }
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
    
    template: Ember.Handlebars.compile("""
    <ul class="nav nav-tabs">
        {{#each tray in view.traysAvailable}}
            <li><a {{action toggleTray tray target="view"}}>{{tray}}</a></li>
        {{/each}}
    </ul>
    
    {{view view.ViewList}}
    """)
    
    toggleTray: (event) ->
        classname = event.context
            
        if @traysActive.contains classname
            @traysActive.remove classname
        else
            @traysActive.add classname
        
    ViewList: Ember.CollectionView.extend(
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
