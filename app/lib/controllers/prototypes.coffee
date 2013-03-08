require "nrt-webui/core"

App.PrototypesController = Ember.ArrayController.extend(
    content: []

    # Return set of unique directories
    directories: (->
        dirs = new Ember.Set([]);

        @get('content').forEach (item) =>
            path = item.get('logicalPath')
            path = path.split('/')
            path[0] = 'root'
            path.pop() # Just the parent

            # Construct all intermediate directories
            while path.length
                dirs.add path.join('/')
                path.pop()

        return dirs
    ).property('content.@each')
)
