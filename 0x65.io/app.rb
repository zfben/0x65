# rubygems required
require 'rubygems'
require 'bundler/setup'
Bundler.require
require 'yaml'

APP_ROOT = File.dirname(__FILE__)

# set sinatra's variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, "views"
set :public, "public"

# compass (Sass toolkit) config
configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
end

# routes

get '/stylesheets/:file' do
  file = params[:file].gsub(/\.css/, '')
  if File.exists?(File.join('views', 'sass', file + '.sass'))
    content_type 'text/css', :charset => 'utf-8'
    sass :"sass/#{file}"
  else
    404
  end
end

get '/*' do
  if params[:splat] == ['']
    file = 'index'
  else
    file = params[:splat][0].gsub(/\.html/, '')
  end
  if File.exists? File.join('views', 'pages', file + '.haml')
    haml :"pages/#{file}", {
      :layout => :'layouts/application'
    }
  else
    404
  end
end
