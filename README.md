I18n web translator
===================

This application is very simple working demonstration of using
i18n-translators-tools. If you want to try it just download it enter the
directory and run ruby start.rb

For managing your locales look at [i18n-translators-tools][1] gem and the
i18n-translate tool. It can merge and propagate changes and convert to
different formats (yml, rb, po).


Dependencies
-------------

* i18n
* i18n-translators-tools
* ramaze


Installation
------------

**Installing dependencies**

    gem install i18n i18n-translators-tools ramaze
  
**Downloading translator**

    git clone http://github.com/pejuko/i18n-web-translator.git

**Running**

    cd i18n-web-translator
    ruby start.rb

now point your browser to [http://localhost:7000/][2]


Using I18n web translator to translating your own project
---------------------------------------------------------

Well, this is really very simple application without user authentication but
if you want to use it behind firewall on your own project just exchange locales
in locale directory for your own and rerun translator.

This application doesn't support nested locale directories even that
i18n-translate tools does.


WARNING
-------

Because i18n-translate can NOT handle lambdas and procs objects you should store
them in different sub-directory and set exclude in locale config
(see [i18n-translators-tools][1] project how)


  [1]: http://github.com/pejuko/i18n-translators-tools
  [2]: http://localhost:7000/
