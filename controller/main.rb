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
    @projects = Project.all
  end

  # create new project
  def create
    if request.post? and request["project_name"] and request["new_project"]
      Project.create(request["project_name"])
    end
    redirect_referer
  end

  # only switch to different locales
  def switch_locale(locale)
    session[:lang] = locale
    redirect "/"
  end

end
