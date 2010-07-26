I18n web translator
===================

This is very simple project-based application for translating locales using
i18n-translators-tools. If you want to try it just download it enter the
directory and run ruby start.rb

For managing your locales look at [i18n-translators-tools][1] gem and the
i18n-translate tool. It can merge and propagate changes and convert to
different formats (yml, rb, po, ts, properties).


Interesting features
--------------------

* various formats support (yml, rb, po, ts, properties)
* nested directories
  * can work with locales in nested directories
  * creates new locale in every subdirectory respecting .i18n-translate config
    in the project directory (you can set there e.g.: :exclude => ['rules'])
  * if you create new subdirectory using web translator it automaticaly creates
    empty locale file for all language in actual format.
  * default file for every nested directory
* no database required
* various scenarios possible
  * e.g: you can have default file in yaml and other locales in po.


WARNING
-------

* **enhanced format** for rb and yml file it uses enhanced format used by
  [i18n-translators-tools][1]. If you want to use it with ruby i18n library
  you either have to strip all extra metadata (after you copy files somewhere):

      i18n-translate strip

  or you have to configure and include correct backends in your application eg:

      I18n::Backend::Simple.send(:include, I18n::Backend::PO)
      I18n::Backend::Simple.send(:include, I18n::Backend::Translate)
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.default_locale = 'default'
      I18n.load_path << Dir[ File.expand_path("../locale/default.yml", __FILE__) ]
      I18n.load_path << Dir[ File.expand_path("../locale/*.po", __FILE__) ]
      I18n.locale = 'cs'

      I18n.t("some.key.there")

* Because i18n-translate can NOT handle lambdas and procs objects you should store
  them in different sub-directory and set exclude in project config file
  (see [i18n-translators-tools][1] project how)

* **no authentication or authorization**
* **raise conditions are possible** if more people edit the same file


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

1. Create a new project in the translator.
2. copy your locales to project/<project_dir>
3. start translating


  [1]: http://github.com/pejuko/i18n-translators-tools
  [2]: http://localhost:7000/

<!--
vi: filetype=mkd
-->
