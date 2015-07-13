---
layout: post
title:  The module system in Nodejs
date:   2015-07-05 01:35:20
tags: javascript nodejs
---
The module system in nodejs is very interesting as it is extremely simple but still powerful enough to help developers organize their code. Nodejs encourages the use of modular structure for pretty much everything from a simple utility function or complex model class.

There is a good amount of information in the main [module page](https://nodejs.org/api/modules.html). Therefore, I will not go deep into any of the technical part of it (I probably don't know that much anyway). 

## A short introduction to `require`
Conceptually, a module is a container for code that can be reused. As the core of the module system is the mighty `require` function. The easiest way (in my opinion) to understand what is really going on when using `require` is to use `strace` to know what is actually done behind the scene.

{% highlight bash %}
strace -e trace=stat node -e "require('not_existed')"
stat("/home/blog/node_modules/not_existed", 0x7fff68803198) = -1 ENOENT (No such file or directory)
stat("/home/blog/node_modules/not_existed.js", 0x7fff68803148) = -1 ENOENT (No such file or directory)
stat("/home/blog/node_modules/not_existed.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/node_modules/not_existed.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/node_modules/not_existed/index.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/node_modules/not_existed/index.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/node_modules/not_existed/index.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed", 0x7fff68803268) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed/index.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed/index.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/node_modules/not_existed/index.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed", 0x7fff68803268) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed/index.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed/index.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/node_modules/not_existed/index.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed", 0x7fff2fe6c398) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed.js", 0x7fff2fe6c338) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed.json", 0x7fff2fe6c338) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed.node", 0x7fff2fe6c338) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed/index.js", 0x7fff2fe6c338) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed/index.json", 0x7fff2fe6c338) = -1 ENOENT (No such file or directory)
stat("/tmp/not_existed/index.node", 0x7fff2fe6c338) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed", 0x7fff68803268) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed/index.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed/index.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_modules/not_existed/index.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed", 0x7fff68803268) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed/index.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed/index.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.node_libraries/not_existed/index.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed", 0x7fff68803268) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed/index.js", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed/index.json", 0x7fff68803208) = -1 ENOENT (No such file or directory)
stat("/home/blog/.nvm/v0.10.32/lib/node/not_existed/index.node", 0x7fff68803208) = -1 ENOENT (No such file or directory)
{% endhighlight %}

One does not need to fully understand everything here to know what is going on. Basically, node has its own rules to look for a module. First, it will go from the current directory (`/home/blog`) and search for the module, then go up until it reaches the top level (`/`). Then, it looks into `NODE_PATH`, in my case, it is only `/tmp` but we can have multiple paths. And finally, it goes into some global paths including `nvm` (a small library to manage multiple version of nodejs) paths. In all those paths, node will search for the module in a special folder named `node_modules` and it can't be changed and [never will be](https://docs.npmjs.com/misc/faq#node-modules-is-the-name-of-my-deity-s-arch-rival-and-a-forbidden-word-in-my-religion-can-i-configure-npm-to-use-a-different-folder).

Next, for each path, node searches for `module_name`, `module_name.js`, `module_name.json` or `module_name.node` file. And if it can't find the file, it starts looking for folders with an index file `index.js`, `index.json` or `index.node`. Once it has found the module, the parsing process kicks in and does its things then the module content is cached so that node will not have to repeat the whole process all over again. All modules are expected to have valid javascript code except `.json`.

## Why module?
As a software engineer, I wanted to re-use everything I have every written. It is a best practice to try encapsulating every piece of work when possible and re-use it later.

## How to organize module?
It depends on many factors, personal preferences, code size, module's purpose etc... My favorite way is to start a module with the purpose of releasing it as an open-source project later, so I often go with folder and `index.js` format.

By exposing the module as a folder (with `index.js` file), I am free to organize the internal structure of the module without affecting other modules that depend on it.

## How to design a module?
There are many ways to do this, I have seen several ways after few years working with nodejs

### Exposing object or function directly
{% highlight javascript %}
// mymodule/index.js
module.exports = {
  options: {
    uppercase: false
  },
  greet: function(name) {
    if (this.options.uppercase) {
      name = name.toUpperCase();
    }

    return ['Hello', name].join(' ');
  }
}

// app.js
var mymodule = require('./mymodule');
mymodule.uppercase = true;
console.log(mymodule.greet('Tan'));
{% endhighlight %}

The idea is simple, just exposing whatever needed. However, this approach has one limitation. The options set is propagated globally because the module content is cached by nodejs, only one instance of it is returned. This pattern can be used for global utility modules (logging, database connection etc..) which need to have different settings depending on the environment.
{% highlight javascript %}
if (process.env.NODE_ENV === 'production') {
  mymodule.uppercase = false;
} else {
  mymodule.uppercase = true;
}
{% endhighlight %}

### Exposing factory function
{% highlight javascript %}
// mymodule/index.js
module.exports = function(options) {
  options = options || {};
  options = _.defaults(options, {

  });

  return {
    greet: function(name) {
      if (options.uppercase) {
        name = name.toUpperCase();
      }

      return ['Hello', name].join(' ');
    }
  }
}

// app.js
var mymodule = require('./mymodule')({uppercase: true});
console.log(mymodule.greet('Tan'));
{% endhighlight %} 

There is nothing fancy about this, just exposing the factory function to the 3rd party code. By using a factory function, I will have a chance to initialize the module with options provided by 3rd party code. This approach is often used when dealing with simple modules.

### Exposing constructor function
{% highlight javascript %}
// mymodule/index.js
var MyModule = function(options) {
  options = options || {};
  options = _.defaults(options, {

  });

  this.options = options;
}

MyModule.prototyp.greet = function(name) {
  if (this.options.uppercase) {
    name = name.toUpperCase();
  }

  return ['Hello', name].join(' ');
}

module.exports = MyModule;

// app.js
var MyModule = require('./mymodule');
var instance = new MyModule({uppercase: true});
console.log(instance.greet('Tan'));
{% endhighlight %}

This is a more OOP way to organize the module (and is my favorite). This approach enables further code re-use and allows 3rd party code to add more functionalities without breaking Open-Close principle.

### Which one to use?
For simple modules (utilities, database connection), I often choose factory functions. The main reason is to simplify the module. Another reason is that those modules are pretty much fixed when they are done, it is better to keep them simple.

For more complex stuff (models and controllers), I use constructor functions because they are more flexible, organized and object oriented. Coming from Java background, it is my habit to think in term of classes. I wanted to do something else (like functional programming), but it will take a while to change the way I think.

For the first approach, I have never used it before because I don't like the idea of globally shared objects (global variables are evil). Accidentally changing the options somewhere in the code base will cause unexpected effects somewhere else.