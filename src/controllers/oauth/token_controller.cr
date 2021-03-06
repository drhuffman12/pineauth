module OAuth
  class TokenController < BaseController
    before_action do
      all do
        response.content_type = "application/json"
        set_properties
        halt!(400, error) if error?
      end
    end

    property! client : Client
    property! grant_type : String
    getter basic_auth_user : String?
    getter basic_auth_pass : String?

    def create
      case grant_type
      when "authorization_code"
        respond_token
      when "refresh_token"
        refresh_and_respond_token
      else
        error :server_error
      end
    end

    private def respond_token
      return error :invalid_grant unless (grant = Grant.find_by :code, params["code"]?) && grant.authorize client

      token = AccessToken.new_with_refresh_token(scopes: grant.scopes, user_id: grant.user_id, client_id: grant.client_id)

      if token.valid? && token.save
        grant.revoke
        AccessTokenRenderer.render token
      else
        error :server_error
      end
    end

    private def refresh_and_respond_token
      if (refresh_token = params["refresh_token"]) && (token = AccessToken.refresh(refresh_token, client))
        if token.valid? && token.save
          AccessTokenRenderer.render token
        else
          error :server_error
        end
      else
        error :invalid_grant
      end
    end

    private def set_properties
      return error :invalid_client unless set_basic_authentication && (@client = Client.authenticate(basic_auth_user, basic_auth_pass))
      return error :unsupported_grant_type unless (@grant_type = params["grant_type"]?) && ["authorization_code", "refresh_token"].includes? grant_type
      return error :invalid_request if (redirect_uri = params["redirect_uri"]?) && redirect_uri != client.redirect_uri
    end
  end
end
