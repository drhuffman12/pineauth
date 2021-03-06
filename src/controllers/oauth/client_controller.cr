module OAuth
  class ClientController < ApplicationController
    before_action do
      all { authenticate_developer! }
    end

    def index
      clients = Client.where(user_id: current_user.id)
      render("src/views/oauth/client/index.slang")
    end

    def show
      if client = Client.find_by(id: params["id"], user_id: current_user.id)
        render("src/views/oauth/client/show.slang")
      else
        flash["warning"] = "Client with ID #{params["id"]} Not Found"
        redirect_to "/oauth/clients"
      end
    end

    def new
      client = Client.new
      render("src/views/oauth/client/new.slang")
    end

    def create
      client = Client.new(params.to_h.select(["name", "redirect_uri", "scopes"]))
      client.user_id = current_user.id

      if client.valid? && client.save
        flash["success"] = "Created client successfully."
        redirect_to "/oauth/clients"
      else
        flash["danger"] = "Could not create client!"
        render("src/views/oauth/client/new.slang")
      end
    end

    def edit
      if client = Client.find_by(id: params["id"], user_id: current_user.id)
        render("src/views/oauth/client/edit.slang")
      else
        flash["warning"] = "Client with ID #{params["id"]} Not Found"
        redirect_to "/oauth/clients"
      end
    end

    def update
      if client = Client.find_by(id: params["id"], user_id: current_user.id)
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

    def destroy
      if client = Client.find_by(id: params["id"], user_id: current_user.id)
        client.destroy
      else
        flash["warning"] = "Client with ID #{params["id"]} Not Found"
      end
      redirect_to "/oauth/clients"
    end
  end
end
