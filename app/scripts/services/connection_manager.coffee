"use strict"

#
# Stores connections
# Creates and deletes connections
#
angular.module('nrtWebuiApp').factory('ConnectionManagerService', ($rootScope, ServerService, ModuleManagerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.connections = []

    $rootScope.$on('ServerService.federation_update', (event, federation) ->
        self.connections = federation.connections
    )

    self.createConnection = (poster_port, subscriber_port) ->
        console.log "Create connection from poster to subscriber", poster_port, subscriber_port
        # If no source topic, then generate a random one
        topic = poster_port.topi
        if topic == ""
            topic = 'UnnamedTopic_' + Math.random().toString(36).substring(7)
            # Send message to loader to set poster topic
            ServerService.setPortTopic poster_port, topic

        filter = subscriber_port.topi
        if filter == ""
            # If we have no filter, we can just tune into the topic
            filter = topic
        else
            # Check to see if we're already tuned in
            filters = filter.split('|')

            return if _(filters).contains topic # We're already tuned in, we don't need to do anything

            filter += "|#{topic}"
        # Send message to loader to set checker/subscriber topic filter
        ServerService.setPortTopic subscriber_port, filter

    self.deleteConnection = (connection) ->
        console.log "Delete connection"
        port1 = connection.from_port
        port2 = connection.to_port

        if port1.orientation == 'poster'
            poster = port1
            subscriber = port2
        else
            poster = port2
            subscriber = port1

        # Have the subscriber stop tuning in
        topic = poster.topi
        filters = subscriber.topi.split('|')
        filtered_filters = _(filters).reject (filter) -> filter == topic

        new_filter = filtered_filters.join('|')
        ServerService.setPortTopic subscriber, new_filter

    return self
)
