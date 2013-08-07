"use strict"

angular.module("nrtMessageConsoleApp").controller "MessageConsoleCtrl", ($scope) ->

    $scope.INFO    = 0
    $scope.DEBUG   = 1
    $scope.WARNING = 2
    $scope.FATAL   = 3

    $scope.filter_levels  = [$scope.DEBUG, $scope.INFO, $scope.WARNING, $scope.FATAL]
    $scope.filter_fields  = ['module', 'message']
    $scope.filter_string  = ''

    $scope.hasFilterLevel = (level) ->
        return _($scope.filter_levels).contains level

    $scope.toggleFilterLevel = (level) ->
        if $scope.hasFilterLevel(level)
            $scope.filter_levels = _($scope.filter_levels).without level
        else
            $scope.filter_levels.push level

    $scope.hasFilterField = (field) ->
        return _($scope.filter_fields).contains field

    $scope.toggleFilterField = (field) ->
        if $scope.hasFilterField(field)
            $scope.filter_fields = _($scope.filter_fields).without field
        else
            $scope.filter_fields.push field


    $scope.messageFilter = (message) ->
        return true if $scope.filter_fields.length == 0

        return false unless _($scope.filter_levels).contains message.level

        for field in $scope.filter_fields
            return true if (message[field].indexOf($scope.filter_string) != -1)

        return false

    $scope.clearMessages = ->
        $scope.messages = []

    $scope.messages = [
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "XXX Lorem ipsum dolor sit amet, consectetur adipiscing elit"
            level: $scope.DEBUG
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
            level: $scope.INFO
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
            level: $scope.WARNING
        },
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
            level: $scope.INFO
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
            level: $scope.FATAL
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
            level: $scope.INFO
        },
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
            level: $scope.DEBUG
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
            level: $scope.WARNING
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
            level: $scope.WARNING
        },
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
            level: $scope.INFO
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
            level: $scope.FATAL
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
            level: $scope.INFO
        },
    ]

