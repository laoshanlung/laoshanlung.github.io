---
layout: post
title:  Dependency Injection in Nodejs
date:   2015-08-31 22:41:48
tags: javascript nodejs
---

Dependency Injection is not a new concept, it has been around as long as I know how to write code. In one of my side projects where I am using AngularJS for the client-side and good old plain nodejs for the server-side, I realize that having 2 ways of "requiring" dependencies (the Angular way and the CommonJS way) is kind of frustrating and hard to follow. After spending some time thinking, I finally found a solution to bring Angular's way of injecting dependencies to Nodejs

The idea is simple, I started with how I wanted to write my module using the "imaginary" dependency injection system.

{% highlight javascript %}
module.exports = function BaseModel(Backbone) {
    return Backbone.Model.extend({

    });
};
{% endhighlight %}

I am a big fan of Backbone, so I will use backbone to create my base model from which all other models will extend. The idea is simple, by using the function name as the module name and the parameters as the dependencies, I can have a simple dependency injection system (not as elegant as Angular's but it works for my case).

From the prototype, there are 2 things needed to be done

1. Extract the function name and use it as the module name
2. Extract the list of arguments as strings and use them to inject dependencies to the module

Extracting the function name is simple, just call `fn.name`. Extracting the argument list as strings is a bit trickier. First thing first, I need to somehow get the list of arguments as I specify in the code. The simplest way is to call `fn.toString()`

{% highlight javascript %}
function BaseModel(Backbone) {};
BaseModel.toString(); // will output function BaseModel(Backbone) {}
{% endhighlight %}

Now that I have a string represented my function, the next step is to extract all the arguments. It sounds like a perfect task for Regex. But... I am terrible at Regex, so I googled and found this [solution](http://stackoverflow.com/a/9924463), I am going to use it instead of banging my head against the wall trying to come up with a regex.

After solving those 2 fundamental problems, it's time to actually write something that can keep track of all the dependencies.

## The injector structure
At its simpliest form, the injector needs to have the following methods
{% highlight javascript %}
module.exports = {
    module: function(name, fn) {},
    inject: function(name) {}
};
{% endhighlight %}

- `module` is to register a new module to the DI system
- `inject` is to get the registered module

The usage is simple, first I need to register something
{% highlight javascript %}
injector.module('BaseModel', require('./models/base'));
// or just
injector.module(require('./models/base'));
{% endhighlight %}

Then, I can inject the base model in other part of the project
{% highlight javascript %}
var BaseModel = injector.inject('BaseModel');
{% endhighlight %}

Or use it as a dependency to another module
{% highlight javascript %}
module.exports = function Account(BaseModel) {
    return BaseModel.extend({});
};
{% endhighlight %}

## Lazy load modules
One of the problems that I first encounter is how to make sure that all dependencies are resolved before initializing the injected module. I solved this problem by lazy loading all the modules.

When first calling `module` to register new module, the injector doesn't really do anything but store the module data in an internal variable
{% highlight javascript %}
function _module(name, fn) {
    if (_.isFunction(name)) {
        fn = name;
        name = fn.name;
    }

    if (!name) {
        throw 'Missing name';
    }

    // allow overwrite previously defined module
    if (self._modules[name]) {
        delete self._modules[name];
    }

    self._maps[name] = {
        deps: _.isFunction(fn) ? getParamNames(fn) : [],
        fn: fn
    };
}
{% endhighlight %}

Then, when calling `inject` to actually get the module, all the dependencies are resolved first using a simple recursive call.

{% highlight javascript %}
function inject(name) {
    ...
    var mod = self._maps[name];
    var deps = mod.deps;
    var fn = mod.fn;

    var intersection = _.chain(_.keys(self._modules)).intersection(deps).value();
    var remaining = _.without.apply(_, _.union([deps], intersection));
    if (remaining.length) {
        // pending deps
        _.forEach(remaining, function(dep) {
            self.inject(dep);
        });
    }

    var resolved = [];
    _.forEach(deps, function(dep) {
        if (self._aliases[dep]) {
            dep = self._aliases[dep];
        }
        resolved.push(self._modules[dep]);
    });

    if (_.isFunction(fn)) {
        self._modules[name] = fn.apply(null, resolved);
    } else {
        self._modules[name] = fn;
    }

    return self._modules[name];
}
{% endhighlight %}

## Why?
Using the default CommonJS module in nodejs is great for many things but when it comes to unit tests where I need to mock libraries, it becomes complicated and hard to follow.

For example, imagine that we have to test a project that connects to a Postgresql server. Ideally we will have a library to encapsulate the part that sends queries to Postgresql

{% highlight javascript %}
// libs/postgres.js
module.exports = {
    send: function(query) {}
}
{% endhighlight %}

Now in some service, we want to send a query
{% highlight javascript %}
// services/user.js
var psql = require('../libs/postgres');
module.exports = {
    createUser: function(params) {
        // do some stuff
        var query = ...;
        return psql.send(query);
    }
}
{% endhighlight %}

Then, we need to write some unit tests that don't need to connect to the real Postgresql server.
{% highlight javascript %}
// services/user.spec.js
var psql = require('../libs/postgres');
psql.send = jasmine.createSpy();
var userService = require('./user');
{% endhighlight %}

The problem with the above approach is that we have to touch the real postgres module which makes it an unecessary dependency for our tests.

With the DI system, we can break the dependency between the test and the postgres module by providing a mock postgres module.

{% highlight javascript %}
// libs/postgres.js
module.exports = function postgres() {
    return {
        send: function(query) {}
    };
}

// services/user.js
module.exports = function userService('postgres') {
    return {
        createUser: function(params) {
            // do some stuff
            var query = ...;
            return psql.send(query);
        }
    }
}

// services/user.spec.js
injector.module('postgres', require('../mocks/postgres'));
var userService = injector.inject('userService');
{% endhighlight %}

## The complete module
I have put all the code together and publish a module here [https://github.com/laoshanlung/injt](https://github.com/laoshanlung/injt)