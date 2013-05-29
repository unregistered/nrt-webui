get = Ember.get

fmt = Ember.String.fmt

Ember.View.reopen templateForName: (name, type) ->
  return unless name
  templates = get(this, "templates")
  template = get(templates, name)
  unless template
    try
      template = require(name)
    catch e
      throw new Ember.Error(fmt("%@ - Unable to find %@ \"%@\".", [this, type, name]))
  template

# Ember-observable window attributes
window.Window = Ember.Object.create(
  height: $(window).height()
  width: $(window).width()
)
$(window).resize ->
    Ember.set 'Window.height', $(window).height()
    Ember.set 'Window.width', $(window).width()
