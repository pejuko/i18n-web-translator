# -*- coding: utf-8 -*-
# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout :default
  helper :xhtml
  helper :aspect # enables before {}
  engine :Etanni

  COLORS = {
      :ok => "#35d035",
      :changed => "#ffaa33",
      :untranslated => "#e03535",
      :incomplete => "#eeee00"
  }

  before_all {
    I18n.locale = session[:lang] || 'en'
    session[:opts] ||= {}
    @colors = COLORS.dup
  }
end

# Here go your requires for subclasses of Controller:
require __DIR__('main')
