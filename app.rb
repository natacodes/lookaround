#!/usr/bin/env ruby

# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'sinatra/base'
require 'slim'
require 'sass'
require 'coffee-script'

# Application:::::::::::::::::::::::::::::::::::::::::::::::::::
class SassHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/templates/sass'

    get '/css/*.css' do
        filename = params[:splat].first
        sass filename.to_sym
    end
end
#dd
class CoffeeHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/templates/coffee'

    get "/js/*.js" do
        filename = params[:splat].first
        coffee filename.to_sym
    end
end

class MyApp < Sinatra::Base
    use SassHandler
    use CoffeeHandler

    # Configuration:::::::::::::::::::::::::::::::::::::::::::::::
    set :public_dir, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/templates'

    # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::
    get '/' do
        slim :index
    end

    # get '/*' do
    #   path = params[:splat].first
    #   #redirect path
    #   #send_file File.expand_path(path, settings.public_folder)
    #   send_file File.join(settings.public_folder, "../#{path}")
    # end

end

if __FILE__ == $0
    MyApp.run! :port => 8000, :bind => '10.0.1.10'
end
