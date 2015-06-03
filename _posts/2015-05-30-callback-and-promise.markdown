---
layout: post
title:  Callback and promise
date:   2015-05-30 18:34:59
tags: javascript
---

Callback is the basic knowledge that every Javascript developer must know no matter what **side** (client or server) they are working on. It is the fundamental of asynchronous IO operations in Javascript. Then, there is Promise which is a specification aiming to hide the complexity and ugliness of callbacks.

## Good old callbacks
First thing first, when I started with Javascript years ago, the first thing that I learnt was how to use callbacks to listen to events in the browser. When Nodejs came out, callbacks are used everywhere in the core libraries (`fs` for instance). The first problem that I encountered when using callbacks is how to deal with sequential operations that depend on each other. With normal synchronous operations, it is straightforward

{% highlight javascript %}
try {
  var result1 = operation1();
  var result2 = operation2(result1);
} catch (e) {
  handleError(e)
}
{% endhighlight %}

However, this becomes a nightmare with callbacks a.k.a callback hell

{% highlight javascript %}
operation1(function(error, result1){
  if (error) return handleError(error);
  operation2(result1, function(error, result2){
    if (error) return handleError(error);
  });
});
{% endhighlight %}

It is not only hard to read but also repetitive in error handling process. Each callback needs to handle error seperately. There are many libraries to help solve this kind of nightmare, I used `async` few years ago.

{% highlight javascript %}
async.waterfall([
  operation1,
  operation2
],  function(error, result){
  if (error) return handleError(error);
});
{% endhighlight %}

It looks neat, all the errors are handled in one place. The flow is easier to read and follow. But is still not quite satisfied, I wanted something more organized and more OOP. With libraries like `async`, although I can have a certain level of structure in my code, but I still have to repeatedly call `async.waterfall` or whatever methods to control the flow. As a lazy person, I don't want to do that.

## Modern Promises
Promise is **NOT** a concrete implementation as many people often misunderstand, it is a specification. Promise aims to provide a better way to deal with asynchronous operations. Its main idea is to have asynchronous operations returned an object that has `then` method instead of relying on callbacks. The `then` method receives 2 callbacks, one to handle the successful result and the other one to handle error. Considering the above example, with Promise, all the operations can easily be chained together.

{% highlight javascript %}
operation1().then(operation2).then(function(result){
  
}, function(error){
  handleError(error);
});
{% endhighlight %}

One of the most annoying things with callback is that it does not support `throw` statement, when I want to terminate the execution flow, I must return the callback with the first param set to the error (NodeJS convention). With Promise, I can simply throw the error just like I do with synchronous code

{% highlight javascript %}
operation1().then(operation2).then(function(result){
  throw new MyException();
}).then(function(result){
  
}, function(error){
  // catch MyException here
});
{% endhighlight %}

In most of Promise implementations, there is a `catch` method that can be used to catch all the errors.

{% highlight javascript %}
operation1().then(operation2).then(function(result){
  throw new MyException();
}).catch(function(error){
  // catch MyException here
}).then(function(result){
  
});
{% endhighlight %}

It looks pretty close to the flow of synchrnous code, operations are ran one after another, exceptions are handled nicely in one place.

## Common mistakes in asynchronous programming (and promise)
### Wrong context
Context is important, especially in closures

{% highlight javascript %}
var MyClass = function() {
  
}

MyClass.prototype.method1 = function() {
  // this here refers to the current MyClass instance
  return someAsyncStuff().then(function(){
    // inside this closure, this refers to the global object (global in Nodejs and window in Browser)
  });
}
{% endhighlight %}

To solve this, the simplest way is to save the context to a different variable `self = this` is the common way. Another way is to use `bind` but it comes with a huge performance problem since `bind` is **sooo slow**

{% highlight javascript %}
MyClass.prototype.method1 = function() {
  return someAsyncStuff().then(function(){
    // now this is my instance
  }.bind(this));
}
{% endhighlight %}

### Incorrectly return promises or forget to return
{% highlight javascript %}
var result = instance.method1().then(function(){
  instance.method2().then(function(){
    return 1;
  });
});

result.then(function(data){
  
});
{% endhighlight %}

This is one typical example that developers who are new to promise often make (or even experienced developers who simply forget to return). It is obvious that `data` will be `undefined` because the function provided to `then` returns `undefined` (in Javascript missing return statement is the same as returning `undefined`). The correct code should be

{% highlight javascript %}
var result = instance.method1().then(function(){
  return instance.method2().then(function(){
    return 1;
  });
});
{% endhighlight %}

Well it looks a bit ugly, let's refactor it using `bind` although it is slow
{% highlight javascript %}
var result = instance.method1().then(instance.method2.bind(instance)).then(function(){
  return 1;
});
{% endhighlight %}

Much better now, but `bind` is a huge performance hurdle when using is highload environment.

### Wrong chain
There are cases that I need to generate a promise chain based on some certain conditions.

{% highlight javascript %}
var promise = instance.method1();
if (condition) {
  promise.then(instance.method2A.bind(instance));
} else {
  promise.then(instance.method2B.bind(instance));
}

promise.then(print);
{% endhighlight %}

If not understand promises, one would expect that `instance.method1` runs first, then depending on the `condition`, `method2A` or `method2B` will run after that. And finally, `print`. In reality, only `print` runs. The thing is that calling `then` multiple times on a promise object does not result in sequential execution of closures. Instead, the last call will set the closure for that promise. So, the above code should be refactored to

{% highlight javascript %}
var promise = instance.method1();

if (condition) {
  promise = promise.then(instance.method2A.bind(instance));
} else {
  promise = promise.then(instance.method2B.bind(instance));
}

promise.then(print);
{% endhighlight %}

By assigning a new promise object, `then` can work properly. In some promise implementation, there are tools to support this kind of sequential execution, `when` for example
{% highlight javascript %}
var sequence = require('when/sequence');
var tasks = [];

tasks.push(instance.method1);
if (condition) {
  tasks.push(instance.method2A.bind(instance));
} else {
  tasks.push(instance.method2B.bind(instance));
}
tasks.push(print);

sequence(tasks);
{% endhighlight %}

There are many other silly mistakes that I made during my years of Javascript development, but those 3 are the most common ones that I can remember for now.