# -*- coding: utf-8 -*-
# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class ProjectController < Controller

  # the index action is called automatically when no other action is specified
  def index(base_dir)

    # save changes
    if request.post? and request["translation"]
      @translate.assign(request["translation"])
      @translate.export!
      @translate.reload!
      I18n.reload!
    end 

    # get list of available locales
    @locales = get_locales(@project.config)

    # get list of available directories
    @subdirs = get_dirs(@project_lang, @project.config)
    @locale_files = get_locale_files(@project_lang, @project.config)
    
    # compute some statistics
    @stat = @translate.stat
    if @stat[:total] > 0
      @progress_i = ((@stat[:ok] + @stat[:changed] + @stat[:incomplete]).to_f / @stat[:total].to_f) * 100 
      @progress_c = ((@stat[:ok] + @stat[:changed]).to_f / @stat[:total].to_f) * 100 
      @progress_t = (@stat[:ok].to_f / @stat[:total].to_f) * 100 
    end
  end

  # change project title, description, url, settings
  def edit(*args)
    if request.post? and request["save"]
      @project.homepage = request["homepage"].to_s.strip
      @project.name = request["name"].to_s.strip
      @project.description = request["description"].to_s.strip
      @project.save
    end
  end

  def create_default(*args)
    if request.post? and request["create_default"] and request["default_name"]
      name = request["default_name"]
      format = request["default_format"]
      default = {name => {}}
      @project.config[:default] = name
      @project.config[:default_format] = format
      @project.save
      filename = File.join(Project::PROJECT_DIR, @project.base_dir, %~#{name}.#{format}~)
      I18n::Translate::Processor.write(filename, default, @translate)
    end

    redirect_referer
  end

  # create locale
  def create_locale(*args)
    if request.post? and request["create_locale"] and request["locale_name"]
      name = request["locale_name"]
      format = request["locale_format"]
      config = @project.config.dup
      config[:format] = format
      get_dirs(@translate.lang, @project.config).each do |path|
        dir = File.join(@project.config[:locale_dir], path)
        next unless File.directory?(dir)
        config[:locale_dir] = dir
        t = I18n::Translate.create_locale(name, config)
      end
    end

    redirect_referer
  end

  # add new field to default
  def create_entry(*args)
    if request.post? and request["create_entry"] and request["new_key"] and request["new_default"]
      key = request["new_key"]
      value = request["new_default"]
      I18n::Translate.set(key, value, @translate.default, @translate.options[:separator])
      default = {@translate.options[:default] => @translate.default}
      I18n::Translate::Processor.write(@translate.default_file, default, @translate)
    end
  
    redirect_referer
  end

  # only switch to different locales
  def switch_locale(*args)
    if request["project_lang"]
      session[:project_lang] = request["project_lang"]
    end
    redirect_referer
  end

  # switch default directory
  def change_file(*args)
    if request.post? and request["change_file"] and request["locale_file"]
      locale_file = request["locale_file"]
      redirect_referer if locale_file =~ /\.\./
      dir = File.dirname(locale_file)
      file = File.basename(locale_file)
      lang, format = $1, $2 if file =~ /(.+)\.([^.]+)$/
      redirect_referer unless lang and format
      session[:project_lang] = lang
      session[:project_format] = format
      session[:project_path] = @project.config[:locale_dir].dup
      session[:project_path] << "/#{dir}" if dir != "."
    elsif request.post? and request["create_dir"]
      path = File.join(@project.config[:locale_dir], request["directory"])
      subdir = request["subdirectory"]
      redirect_referer if path =~ /\.\./
      redirect_referer if subdir =~ /\.\./
      redirect_referer unless path =~ /^#{@project.config[:locale_dir]}/
      trg = File.join(path, subdir)
      Dir.mkdir(trg)
      default = File.basename(@translate.default_file)
      I18n::Translate::Processor.write(File.join(trg, default), {@translate.options[:default] => {}}, @translate)
      locales = get_locales(@project.config)
      format = 'yml'
      format = $1 if @translate.lang_file =~ /\.([^\.]+)$/
      locales.each do |lang|
        I18n::Translate::Processor.write(File.join(trg, "#{lang}.#{format}"), {@translate.lang => {}}, @translate)
      end
    end
    redirect_referer
  end

  protected

  def get_locales(config)
    locales = []
    I18n::Translate.scan(config) do |tr|
      locales << tr.lang
    end
    locales.sort!
    locales.uniq!
    locales
  end

  def get_locale_files(lang, config)
    opts = config.dup
    opts[:locale] = lang
    opts[:deep] = true
    locale_files = I18n::Translate.scan(opts).sort.map{ |f|
      f =~ /^#{Project::PROJECT_DIR}\/#{@project.base_dir}\/(.+)/
      $1
    }
    locale_files
  end

  def get_dirs(lang, config)
    subdirs = []
    locale_files = get_locale_files(lang, config)
    subdirs = locale_files.map{|x| File.dirname(x)}
    subdirs.sort!
    subdirs
  end

  def init_controller
    # set current locales
    @lang = I18n.locale
    session[:project_lang] ||= @lang.to_s
    @project = Project.new(action.params.first)
    @project_lang = session[:project_lang]
    @project_format = session[:project_format] || "auto"
    opts = @project.config.dup
    opts[:format] = @project_format
    opts[:locale_dir] = session[:project_path] if session[:project_path]
    @translate = ::I18n::Translate::Translate.new( @project_lang, opts )
  end

end
