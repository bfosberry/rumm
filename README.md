## Rumm: a tasty tool for hackers and pirates

[![Gem Version](https://badge.fury.io/rb/rumm.png)](http://badge.fury.io/rb/rumm)
[![Build Status](https://travis-ci.org/rackerlabs/rumm.png?branch=master)](https://travis-ci.org/rackerlabs/rumm)
[![Dependency Status](https://gemnasium.com/rackerlabs/rumm.png)](https://gemnasium.com/rackerlabs/rumm)


Rumm is a command line interface and API to rackspace. You can use it
to easily build and manage infrastructure for great good.


## Usage

Authenticate with rackspace using your cloud credentials as follows:

    rumm login
      username: joe
      password: ****
      Default Region (Enter for ord):
      logged in, credentials written to ~/.rumm

Now we can see the list of servers we have available:

    $ rumm show servers
    you don't have any servers, but you can create one by running:
    rumm create server

Create the server:

    rumm create server
      created server divine-reef
        id: 52415800-8b69-11e0-9b19-734f565bc83b, hostId: e4d909c290d0fb1ca068ffaddf22cbd0, ip: 67.23.10.138, image: CentOS 5.2

To use rumm out side of your default region, prefix the rumm command with the `REGION` environment variable as follows:

  REGION=syd rumm create server

For further help, including a full listing of commands, type:

    rumm help

## Further Reading

See the [official rumm website][1] for more information, including documentation.

[1]: http://rackerlabs.github.io/rumm
