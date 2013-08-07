require "spec_helper"
require 'io/console'

describe "logging in" do
  Given do
    # @announce_dir = true
    # @announce_cmd = true
    # @announce_env = true
    # @announce_stdout = true
    # @announce_stderr = true
    @home = Pathname(set_env "HOME", File.expand_path(current_dir))
  end
  context "interactively with valid credentials" do
    When do
      VCR.use_cassette('successful-login') do
        if VCR.current_cassette.recording?
          print "\nUsername: "
          username = $stdin.gets.chomp
          print "Password: "
          password = $stdin.noecho(&:gets).chomp
          print "\nDefault Region (Enter for #{Rumm::Configuration.region}): "
          region = $stdin.gets.chomp
        end
        will_type username || "<username>"
        will_type password || "<password>"
        will_type region || "<region>"
        run_interactive "rumm login"
        stop_process @interactive
      end
    end
    Then {last_exit_status == 0}

    context "places your login credentials in your .rumm" do
      Given(:user) { Rumm::Configuration.username }
      Given(:password) { Rumm::Configuration.api_key }
      Given(:region) { Rumm::Configuration.region }

      Then { user != nil }
      And { password != nil }
      And { region != nil }
    end
  end

  context "logging out" do
    When {VCR.use_cassette('successful-logout') {run "rumm logout"}}
    Then {last_exit_status == 0}

    context "removes your login credentials from .rumm" do
      Then do
        !File.exists?(Rumm::Configuration.instance.send :default_path)
      end
    end
    context "interactively with invalid credentials" do
      When do
        VCR.use_cassette("unsuccessful-login") do
          will_type "nil"
          will_type "nil"
          will_type "\n"
          run_interactive "rum login"
          stop_process @interactive
        end
      end
      Then {last_exit_status != 0}
      And {all_stderr =~ /User could not be authenticated/}
    end
  end
end
