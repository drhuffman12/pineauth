module OAuth
  class ClientController < ApplicationController

    before_action do
      all { authenticate_user! }
    end

    def index
      if_user do
        clients = OAuth::Client.all("WHERE user_id = $1", [user.id])
        render("src/views/oauth/client/index.slang")
      end
    end

    def show
      if_user do
        if client = OAuth::Client.all("WHERE id = $1 and user_id = $2", [params["id"], user.id]).first
          render("src/views/oauth/client/show.slang")
        else
          flash["warning"] = "Client with ID #{params["id"]} Not Found"
          redirect_to "/oauth/clients"
        end
      end
    end

    def new
      if_user do
        client = OAuth::Client.new
        render("src/views/oauth/client/new.slang")
      end
    end

    def create
      if_user do
        client = OAuth::Client.new(params.to_h.select(["name", "redirect_uri", "scopes"]))
        client.user_id = user.id

        if client.valid? && client.save
          flash["success"] = "Created client successfully."
          redirect_to "/oauth/clients"
        else
          flash["danger"] = "Could not create client!"
          render("src/views/oauth/client/new.slang")
        end
      end
    end

    def edit
      if_user do
        if client = OAuth::Client.all("WHERE id = $1 and user_id = $2", [params["id"], user.id]).first
          render("src/views/oauth/client/edit.slang")
        else
          flash["warning"] = "Client with ID #{params["id"]} Not Found"
          redirect_to "/oauth/clients"
        end
      end
    end

    def update
      if_user do
        if client = OAuth::Client.all("WHERE id = $1 and user_id = $2", [params["id"], user.id]).first
          client.set_attributes(params.to_h.select(["name", "redirect_uri", "scopes"]))
          if client.valid? && client.save
            flash["success"] = "Updated client successfully."
            redirect_to "/oauth/clients"
          else
            flash["danger"] = "Could not update client!"
            render("src/views/oauth/client/edit.slang")
          end
        else
          flash["warning"] = "Client with ID #{params["id"]} Not Found"
          redirect_to "/oauth/clients"
        end
      end
    end

    def destroy
      if_user do
        if client = OAuth::Client.all("WHERE id = $1 and user_id = $2", [params["id"], user.id]).first
          client.destroy
        else
          flash["warning"] = "Client with ID #{params["id"]} Not Found"
        end
        redirect_to "/oauth/clients"
      end
    end
  end
end