require "net/https"
require "json"
require "excon"
require 'rumm/configuration'

class AuthenticationController < MVCLI::Controller

  requires :user

  def login
    login_info = user
    username = login_info.name
    password = login_info.password

    uri = URI.parse(Rumm::Configuration.auth_endpoint)
    connection = Excon.new(uri.to_s)

    headers = {'Content-Type' => 'application/json'}
    body = {auth: {passwordCredentials: {username: username, password: password}}}

    response = connection.post headers: headers, body: body.to_json, path: "#{uri.path}/tokens"

    #TODO check the status code of the request
    user_info = Map(JSON.parse response.body)

    #Test if it's authenticated
    fail "User could not be authenticated" unless user_info[:access]

    headers.merge!({'X-Auth-Token' => user_info.access.token.id})
    response = connection.get headers: headers, path: "#{uri.path}/users/#{user_info.access.user.id}/OS-KSADM/credentials/RAX-KSKEY:apiKeyCredentials"

    user_credentials = Map(JSON.parse response.body)

    Rumm::Configuration.username = username
    Rumm::Configuration.api_key = user_credentials["RAX-KSKEY:apiKeyCredentials"].apiKey
    Rumm::Configuration.region = login_info.region
    Rumm::Configuration.save

    user_info
  end

  def logout
    Rumm::Configuration.delete
  end

end
