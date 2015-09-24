---
layout: post
title:  API design part 1
date:   2015-09-18 22:24:43
tags: api javascript nodejs
---
Having APIs is a common thing for web applications nowadays. In one of my previous projects, I was in charge of designing an API system for the web interface and 2 mobile applications to consume. I had a really hard time thinking about the architecture and security for the API system. It took me around 3 days brainstorming and searching all over the Internet for solutions and suggestions. This blog post is my experience learned from more than 2 years building and maintaining the API system.

# Version
Mobile applications are different from web applications in the sense that they usually don't get the latest version. Imaging that we have only 1 API version, and we make some changes that potentially break the old APIs. Our mobile users will have a hard time using our application because everything is broken and they have to upgrade to newer version in order to use it.

There are many solutions to address this kind of problem. The most common one is to put the version number directly in the URL

{% highlight bash %}
/api/1/some/path
{% endhighlight %}

Another solution is to put the version number in the request header `X-API-VERSION=1`. In my opinion, there is not a right/wrong choice here, it is more like personal preferences.

# Path
When it comes to API paths, there are various patterns.

For example, get a product
{% highlight bash %}
GET /api/1/products/1
{% endhighlight %}

or

{% highlight bash %}
GET /api/1/products?id=1
{% endhighlight %}

Update a product
{% highlight bash %}
PUT /api/1/products/1
{
    "name": "name"
}
{% endhighlight %}

or

{% highlight bash %}
PUT /api/1/products
{
    "id": 1,
    "name": "name"
}
{% endhighlight %}

or

{% highlight bash %}
PUT /api/1/products/update
{
    "id": 1,
    "name": "name"
}
{% endhighlight %}

or

{% highlight bash %}
PUT /api/1/products/1/update
{
    "name": 1
}
{% endhighlight %}

Again, there is no right or wrong answer here. In my project, I use this pattern `/api/1/products/update` because it closely resembles the actual file structure in my project.

{% highlight bash %}
.
└── routes
    └── api
        └── 1
           └── products
                ├── list.js
                └── update.js
{% endhighlight %}

Each file is a complete route implementation encapsulating the logic related to that specific path. I also needed to implement a simple module to loop through all the routes and define them in Express.

A sample route file
{% highlight javascript %}
module.exports = {
    type: 'put',
    middlewares: [
        {
            name: 'getProduct',
            extraOption: {},
            anotherOption: true
        }
    ],
    handler: function(req, res, next) {

    }
}
{% endhighlight %}

The `middlewares` option is to simply define a list of middlewares before the actual handler. The above configuration will be translated to the below call to Express API. At the time when I was doing this, Express was at version 3.x and there was no Router available, so everything was added directly to the app object.

{% highlight javascript %}
app.put('/api/1/products/update', middlewares.getProduct({
    extraOption: {},
    anotherOption: true
}), function(req, res, next) {

});
{% endhighlight %}

This approach also has another advantage for the consumers. They don't have to do string concatenation to construct the API paths. They can simply use the paths which are fixed and send whatever data needed in the body or query params.

With this approach, I was able to have 3 different versions of the API running at the same time and more than 40 API end points. Adding new API end point is as simple as creating a new file and define some configurations.

Testing is also easy as each route is isolated and encapsulated, my favorite testing strategy is to place the test files next to their target files.

{% highlight bash %}
.
└── routes
    └── api
        └── 1
           └── products
                ├── list.js
                ├── list.spec.js
                ├── update.js
                └── update.spec.js
{% endhighlight %}

Of course, there are still a lot of things to do (mock middlewares, mock request/response etc...) to actually test those routes, but that is a different topic.