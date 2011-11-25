set :haml, :format => :html5
set :sass, :style => :compressed

configure :build do
  activate :minify_css
end
