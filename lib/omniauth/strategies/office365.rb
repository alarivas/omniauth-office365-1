require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Authentication strategy for connecting with the Office365 API.
    class Office365 < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'office365'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, :site => 'https://graph.microsoft.com/',
                              :authorize_url => 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
                              :token_url => 'https://login.microsoftonline.com/common/oauth2/v2.0/token'

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['Id'] }

      # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema#schema-10-and-later
      info do
        {
          :name => raw_info['displayName'],
          :email => raw_info['userPrincipalName'],
          :nickname => raw_info['Alias']
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('v1.0/me').parsed
      end

      private

      # Overriding this method provided by OmniAuth::Strategies
      #   we don't want the querystring appended to the callback_url
      # See https://github.com/omniauth/omniauth-oauth2/issues/81
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end
  end
end
