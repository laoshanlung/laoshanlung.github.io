---
layout: post
title:  Angular, Flask and Internationalization
date:   2015-05-18 01:51:43
tags: angular javascript python flask
---

One of the problems with today web applications is that the text that needs to be translated does not stay in the server-side anymore. Instead, it is spread throughout the entire code base from server-side components to client-side Javascript templates. It makes the process of internationalization become harder than it already is.

Recently, I have started a fun project that simply crawls through a list of provided urls and pick up all the links it can find, then show them in the main website sorted by tags, date and whatever. Although the interface is simple, the need for supporting multiple languages is real. It is not that my fun project will be used by millions of people from different countries anytime soon. The main reason is to manage all the text and to make my life a bit easier. 

The front-end is built with Angular (along with several other things). The backend is Python with Flask framework and Neo4j with a custom written (and randomly broken) OGM. The internationalization task is done solely by Babel.

From [Babel website](http://babel.pocoo.org/), "Babel is an internationalization library for Python. It has full unicode support and provides access to the CLDR data files. It's widely used and BSD licensed.". Basically, Babel provides a way to use [gettext](https://www.gnu.org/software/gettext/) in your project, and it also manages the process of extracting all the text needed to be translated in your project.

I would not go into details about the setup of Babel in a Flask project, there are several articles, tutorials for that already. **The main issue here is to manage the translations for both client-side and server-side so that Javascript can reuse it**. Also, there should be a way to automatically extract the text for translating from the code in both Angular and Jinja2 (Flask's default template engine) templates.

The process of extracting text from files in Babel is simple, it goes through all the files and looks for certain patterns to extract strings. By default, it looks for things like `gettext`, `ngettext` and `_` in your source code and extract the strings. I will apply the same principle for Angular templates because it has the same syntax

{% highlight html %}
{% raw  %}
{{ gettext('Source') }}: <a title="{{ link.title }}" href="{{ generateLink(true) }}">{{ link.url | domain }}</a> 
{% endraw  %}
{% endhighlight %}

The next step is to provide the function `gettext` and other gettext functions to the templates. I decide to introduce a new translator service instead of adding new functions to the `$rootScope` because I don't want to add too many stuff into the root scope.

{% highlight javascript %}
app.factory('translator', ['$window', function($window){
  var translations = $window._app.translations;
  return {
    gettext: function(text) {
      if (translations[text]) {
        return translations[text];
      }
      return text;
    }
  }
}]);

var directive = function(translator) {
  return {
    link: function($scope, $element, $attr) {
      _.extend($scope, translator);
    }
  };
}

app.directive('singlelink', ['translator', directive]);
{% endhighlight %}

This is a very simple one for demonstration purpose, the actual translator implementation uses [this](https://github.com/mitsuhiko/babel/blob/master/contrib/babel.js). I know that storing data in the global varialbe (`window`) is a bad idea but since this project is small, it won't do any harm. There are better ways to store data such as `localStorage` but that is a different story for another post. Now that I have everything except the actual translations in `$window._app.translations`. The translations come directly from Babel.

{% highlight python %}
@app.context_processor
def common_template_data():
    translations = flask.ext.babel.get_translations()
    locale = flask.ext.babel.get_locale()
    return {
        'env': config.ENV,
        'translations': translations._catalog,
        'locale': locale
        }
{% endhighlight %}

The result is that I have everything centralized in one place. Now comes the extraction part. Fortunately, Jinja2 (default template engine for Flask) and Angular share the same template syntax, I can just reuse the Jinja2 extractor.

{% highlight bash %}
[python: **.py]
[jinja2: **/templates/**.html]
encoding = utf-8
extensions=jinja2.ext.autoescape,jinja2.ext.with_
{% endhighlight %}

This `babel.cfg` file will tell babel to extract all messages in Python source code using the python extractor and all HTML files using Jinja2 extractor. Because my Angular template uses the same syntax it will just work. This simple technique can be used in any other languages (framework). If the template syntax is similar to that of Jinja, the default extractors will work. Otherwise, a custom extractor needs to be implemented.

There is one small problem, the extractor will ignore anything between `raw` tags in Jinja2 templates, but I need to use `raw` tags to render Angular expressions correctly. The solution is simple (but ugly), I can't put the code here since it (again) conflicts with liquid tags. The solution can be found [here](http://pastebin.com/YDQDPD1L)