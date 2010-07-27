# -*- coding: utf-8 -*-
# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

$KCODE="UTF8"
Encoding.default_internal = Encoding.default_external = "UTF-8" if defined?(Encoding)

require 'rubygems'

if RUBY_VERSION == '1.8.6'
  gem 'ramaze', '= 2010.04.04'
end
require 'ramaze'

Ramaze.options.session[:key] = "i18n-web-translator"

require 'i18n-translate'
I18n::Backend::Simple.send(:include, I18n::Backend::Translate)
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.default_locale = 'default'
I18n.load_path << Dir[ File.expand_path("../locale/*.yml", __FILE__) ]

# Make sure that Ramaze knows where you are
Ramaze.options.roots = [__DIR__]

# Initialize controllers and models
require __DIR__('model/project')
require __DIR__('controller/init')
