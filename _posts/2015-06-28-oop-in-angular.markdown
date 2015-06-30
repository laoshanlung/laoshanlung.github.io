---
layout: post
title:  OOP in Angular
date:   2015-06-28 13:26:26
tags: javascript angular
---
Almost everything in Angular is not object oriented by default. While it has its own advantages by ignoring OOP, I often find myself in a situation that I really miss object oriented structure, mainly for reusing code. Thanks to the flexibility of the dependency injection system (`$inject` in particular), I can easily use classes and inheritance in Angular

I was a big fan of Backbone. So, I will use Backbone to illustrate the possibility of reusing code using `$inject` to manage dependencies. I will borrow the `extend` method of Backbone to support inheritance. There are other libraries designed solely for this purpose such as [Class.extend](http://ejohn.org/blog/simple-javascript-inheritance/)

## Controllers and Services
{% highlight javascript %}
var Component = function() {
  this.deps = _.object(Object.getPrototypeOf(this).constructor.$inject, _.values(arguments));
};
Component.extend = Backbone.Model.extend;
{% endhighlight %}

Let's start with the most general "class", this `Component` class does only 1 thing, extracts the dependencies and stores it in `deps` property. The use of `Object.getPrototypeOf(this).constructor.$inject` is to access the `$inject` property set in each controller or service class. Then it borrows `extend` method of `Backbone.Model` to facilitate inheritance.

Next, let's write some services

{% highlight javascript %}
var Service = Component.extend({

}, {
  '$inject': ['anotherFactory']
});

var MyService = Service.extend({
  ask: function() {
    return this.deps['anotherFactory'].ask('How are you?');
  }
});
{% endhighlight %}

Simple inheritance! with `$inject` set to `['anotherFactory']` for all service classes. Then, some controllers

{% highlight javascript %}
var Controller = Component.extend({
  
}, {
  '$inject': ['myFactory', 'myService']
});

var MyController = Controller.extend({
  hello: function() {
    return this.deps['myFactory'].hello('Tan Nguyen');
  },

  ask: function() {
    return this.deps['myService'].ask();
  }
});
{% endhighlight %}

Again, basic inheritance with different dependencies and 2 methods to use them. Now, I can wire everything together in an angular module.

{% highlight javascript %}
angular.module('myApp', [])
.factory('anotherFactory', function(){
  return {
    ask: function(question) {
      return question.toUpperCase() + '?';
    }
  }
})
.factory('myFactory', function() {
  return {
    hello: function(name) {
      return ['Hello, ', name].join('');
    }
  };
})
.service('myService', MyService)
.controller('myController', MyController);
{% endhighlight %}

The two factories above (`anotherFactory` and `myFactory`) can also be rewritten to use OOP style (later in this post). With this kind of setup, I can easily share code between my controllers and services and at the same time enjoy other benefits of OOP such as polymorphism.

## Factories and Directives
I often return objects from my factories, so I will group factories together with directives because they are similar in term of the return data type.

Factories and Directives are a bit tricky to use object oriented style in the sense that their respective angular methods (`angular.factory` and `angular.directive`) expect a [factory function](http://atendesigngroup.com/blog/factory-functions-javascript) instead of a [constructor function](http://pivotallabs.com/javascript-constructors-prototypes-and-the-new-keyword/) in the case of controller and service.

In simple term, when dealing with controller or service, Angular will call `new` on the function that we pass to `angular.controller` or `angular.service`. However, when using `angular.factory` or `angular.directive`, Angular simply invokes the provided function and uses the result.

So, I need to do some tricks to make OOP work properly.
{% highlight javascript %}
var Directive = function() {
  var self = this;
  var $inject = Object.getPrototypeOf(this).constructor.$inject;

  var factory = function() {
    var deps = _.object($inject, Array.prototype.slice.apply(arguments));
    self.deps = deps;

    return {
      link: self.link.bind(self),
      template: self.template
      // other directive-specific functions
    };
  }

  factory.$inject = $inject;

  return factory;
};
Directive.extend = Component.extend;

var MyDirective = Directive.extend({
  link: function($scope, $element, attributes) {
    $scope.name = this.deps['myFactory'].hello('Tan Nguyen');
  },

  template: '<h1>{% raw %}{{ name }}{% endraw %}</h1>'
}, {
  '$inject': ['myFactory']
});

angular.module('myApp', [])
.directive('myDirective', new MyDirective());
{% endhighlight %}

So, normally, when we use `new` the constructor function will return `this` which is the instance object. In order to satisfy Angular, I can just return another factory function which in turn returns the expected object after pre-processing all the dependencies. However, the trick here is to return a new object containing the modified (bound) version of some of the necessary methods for a directive such as `link` and `compile`. The main reason is because the original context is lost during the process of compiling and linking directives. Therefore, even if I `return self`, `this` inside my `link` function still refers to `Window` object.

This is just a demo version with a naive implementation, in the real production version, I will have to properly pre-process all the methods available to directive and all the properties.

For factories, the process is somewhat similar but much simpler
{% highlight javascript %}
var Factory = function() {
  var self = this;
  var $inject = Object.getPrototypeOf(this).constructor.$inject || [];

  var factory = function() {
    var deps = _.object($inject, Array.prototype.slice.apply(arguments));
    self.deps = deps;

    return self;
  }

  factory.$inject = $inject;

  return factory;
};
Factory.extend = Component.extend;
var MyFactory = Factory.extend({
  hello: function(name) {
    return ['Hello, ', name].join('');
  }
});
{% endhighlight %}

In this case I don't need to mess around with the context because Angular is nice enough to keep the original one.