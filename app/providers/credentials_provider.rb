require 'rumm/configuration'

class CredentialsProvider

  def value
    if Rumm::Configuration.username
      Map(username: Rumm::Configuration.username, api_key: Rumm::Configuration.api_key, rackspace_region: Rumm::Configuration.region)
    else
      fail Rumm::LoginRequired, "login required"
    end
  end
end
