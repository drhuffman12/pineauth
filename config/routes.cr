Amber::Server.instance.config do |app|
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    plug Amber::Pipe::CSRF.new
  end

  pipeline :api do
    plug Amber::Pipe::Logger.new
  end

  # All static content will run these transformations
  pipeline :static do
    plug HTTP::StaticFileHandler.new("./public")
    plug HTTP::CompressHandler.new
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", StaticController, :index
  end

  routes :web do
    resources "/users", UserController
    resources "/oauth/clients", OAuth::ClientController
    resources "/oauth/authorized_applications", OAuth::AuthorizedApplicationController, only: [:index, :show, :destroy]
    get "/oauth/authorize", OAuth::AuthorizationController, :new
    post "/oauth/authorize", OAuth::AuthorizationController, :create
    delete "/oauth/authorize", OAuth::AuthorizationController, :destroy

    get "/", HomeController, :index
    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
    delete "/sign_out", SessionController, :destroy
  end

  routes :api do
    post "/oauth/token", OAuth::TokenController, :create
    get "/oauth/token/info", OAuth::TokenInfoController, :show
  end
end
