require 'yaml'
require 'ya2yaml'
require 'i18n'

require __DIR__("../lib/transliter")

class Project
  PROJECT_DIR = "project"

  attr_reader :name, :description, :base_dir, :config, :homepage

  def initialize(dir)
    @base_dir = dir
    path = File.join(PROJECT_DIR, dir)

    @opt_file = File.join(path, ".i18n-translate")
    @config = {}
    @config.merge! I18n::Translate.read_config(@opt_file)
    @config[:locale_dir] = path

    @name = @config[:project_name].to_s.strip
    @description = @config[:project_description].to_s.strip
    @homepage = @config[:project_homepage].to_s.strip
  end

  def self.all
    dirs = []
    Dir["#{PROJECT_DIR}/*"].each do |dir|
      next unless File.directory?(dir)
      dirname = File.basename(dir)
      dirs << Project.new(dirname)
    end
    dirs
  end

  def self.create(name)
    dirname = Project.name_to_dir(name)
    base_dir = File.join(PROJECT_DIR, dirname)
    Dir.mkdir(base_dir)
    config = {
      :project_name => name,
    }
    opt_file = File.join(base_dir, ".i18n-translate")
    File.open(opt_file, "w"){|f| f.write(config.ya2yaml)}
  end

  def self.name_to_dir(name)
    unsafe = /[^-_.'a-zA-Z\d]/
    translit = Transliter.transliterate(name)
    translit.gsub!(unsafe, '-')
    translit.downcase!
    translit.strip!
    translit.gsub!(/--+/, "-")
    translit.gsub!(/__+/, '_')
    translit.gsub!(/(-+|_+)$/, '') 
    translit.gsub!(/^(-+|_+)/, '') 
    translit
  end

  # save config
  def save
    File.open(@opt_file, "w"){|f| f.write(@config.inspect)}
  end

  def name=(value)
    @config[:project_name] = value
    @name = value
  end

  def description=(value)
    @config[:project_description] = value
    @description = value
  end

  def homepage=(value)
    @config[:project_homepage] = value
    @homepage = value
  end

  def method_missing(name, *args)
    if name =~ /([^=]+)=$/
      var = $1.to_sym
      @config[var] = args.first
      self.send(name, args.first) if self.respond_to?(name)
    end
  end

end
