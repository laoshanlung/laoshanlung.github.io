---
layout: post
title:  Angular and minification
date:   2015-05-16 16:37:24
tags: angular javascript
---

Recently, I have started learning Angular, it looks great, everything is pretty abstract and convenient. However there are still a lot of people who are not aware of the (potential) problem when using dependency injection implicitly through the dependency names.

{% highlight javascript %}
angular.module('moduleName').factory('myFactory', function($rootScope){
  
});
{% endhighlight %}

While it has nothing wrong (technically), it will break after being minified. The above code will be (roughly) translated to this this by the minification library

{% highlight javascript %}
a.module('moduleName').factory('myFactory', function(e){
  
});
{% endhighlight %}

It is obvious that the injector will not know what provider to inject to the service `myFactory` since the dependency name has been changed to `e`. So the above code should be rewritten to explicitly state the name of the dependency

{% highlight javascript %}
angular.module('moduleName').factory('myFactory', ['$rootScope', function($rootScope){
  
}]);
{% endhighlight %}

Now, even after the minification process, everything will work as expected. Many people might ask why do we even need minification? There are a couple of reasons for that, but the most important one is to reduce the size of the final Javascript file in order to increase the page load speed.

No, wait, there are more... During the development process of one of my side project using Angular, I ran into this problem with the minification process. In a custom directive that I wrote to use the excellent Masonry library, this minification comes to bite me again.

{% highlight javascript %}
var root = function($timeout, $window, utils) {
  return {
    ...
    controller: function($scope, $element){
      ...
    },
    ...
  };
};
{% endhighlight %}

It looks normal at first, but after running through minification, it becomes this. And Angular starts complaining that it can't find `e` provider. Of course it can't.

{% highlight javascript %}
var root = function($timeout, $window, utils) {
  return {
    ...
    controller: function(e, t){
      ...
    },
    ...
  };
};
{% endhighlight %}

After 10 minutes looking through the minifed code (I was desperate), I finally knew the reason, it turns out that `controller` function is dependency-injected based on what we need (just like normal controllers). `$scope` and `$element` are not automatically provided by Angular. After changing to this, everything works as expected

{% highlight javascript %}
var root = function($timeout, $window, utils) {
  return {
    ...
    controller: ['$scope', '$element', function($scope, $element){
      ...
    }],
    ...
  };
};
{% endhighlight %}

Lessons learned, be aware of the dependencies