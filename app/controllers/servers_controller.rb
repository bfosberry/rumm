class ServersController < MVCLI::Controller
  requires :compute
  requires :command

  def index
    compute.servers.all
  end

  def show
    #What if you have two or more servers with the same name?
    server
  end

  def create
    template = Servers::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    form.validate!
    #Add personalization
    options = {
      name: form.name,
      flavor_id: form.flavor_id,
      image_id: form.image_id,
      private_key_path: form.ssh_private, #"~/.ssh/id_rsa"
      public_key_path: form.ssh_public #"~/.ssh/id_rsa.pub"
    }
    command.output.puts "--> bootstrapping server #{options[:name]}"
    #Progress bar
    server = compute.servers.bootstrap options
    command.output.puts "    done."
    return server
  end

  def destroy
    server.tap do |s|
      s.destroy
    end
  end

  private

  def server
    index.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end

  def generate_name
    'divine-reef'
  end

  def ssh
    test = server
    ip_address = test.ipv4_address
    exec "ssh root@#{ip_address} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q"
  end
end
