# -*- coding: utf-8 -*-
# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class MainController < Controller

  # the index action is called automatically when no other action is specified
  def index
    # set current locales
    @lang = I18n.locale
    @translate = ::I18n::Translate::Translate.new( @lang, session[:opts] )

    # save changes
    if request.post? and request["translation"]
      @translate.assign(request["translation"])
      @translate.export!
      @translate.reload!
      I18n.reload!
    end 

    # get list of available locales
    @locales = []
    I18n::Translate.scan(session[:opts]) do |tr|
      @locales << tr.lang
    end
    
    # compute some statistics
    @stat = @translate.stat
    if @stat[:total] > 0
      @progress_i = ((@stat[:ok] + @stat[:changed] + @stat[:incomplete]).to_f / @stat[:total].to_f) * 100 
      @progress_c = ((@stat[:ok] + @stat[:changed]).to_f / @stat[:total].to_f) * 100 
      @progress_t = (@stat[:ok].to_f / @stat[:total].to_f) * 100 
    end
  end

  # only switch to different locales
  def switch_locale(locale)
    session[:lang] = locale
    redirect "/"
  end

end
