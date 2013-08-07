require 'io/console'

class UserProvider
  requires :command

  def value
    name = get_name
    password = get_password
    region = get_default_region
    Map name: name, password: password, region: region
  end

  private

  def get_name
    command.output.print "Username: "
    command.input.gets.chomp
  end

  def get_password
    command.output.print "Password: "
    password = command.input.noecho(&:gets).chomp
    command.output.print "\n"
    password
  end

  def get_default_region
    command.output.print "Default Region (Enter for #{Rumm::Configuration.region}): "
    region = command.input.gets.chomp
    region.empty? ? Rumm::Configuration.region : region
  end

end
