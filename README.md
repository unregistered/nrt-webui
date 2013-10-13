NRT Designer
==============

![screenshot](http://i.imgur.com/N3xRM3O.png)
Interface to the Neuromorphic Robotics Toolkit. [nrtkit.org](http://nrtkit.org/)

Running
-------

Install dependencies (requires node)

    $ npm install -g bower
    $ npm install -g grunt-cli
    $ npm install

Install client js libraries

    $ bower install

Run the server

    $ grunt server

App Structure
-------------

    nrt-webui
    ├── Gruntfile.js - App build file
    ├── package.json - Node package dependencies
    ├── bower.json - Client-side javascript dependencies, like jquery
    ├── app - App specific code
    │   ├── bower_components - Bower libraries are installed here
    │   ├── styles - App CSS or SCSS (.scss)
    │   ├── views - html templates
    │   ├── scripts - Plugins (e.g. jquery.jsonrpc.js)
    │   │   └── controllers - Angular controllers
    │   │   └── directives - Angular directives modify the DOM
    │   │   └── services - Angular services
    │   │   └── vendor - non-angular js files
    ├── config.ru - Rack development web server configuration
    ├── index.html - The app entry point
    ├── test - Test files
