##General Vagrant environment setup instructions##

From the Vagrant page:

> Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.

 Every project can have its own standard VM, and it drastically speeds up the setup process for someone coming in fresh. Read more at the [vagrant webpage](https://www.vagrantup.com/).

These instructions will enable you to run a Vagrant VM for any project that has a `Vagrantfile`. Default config for this repo is `Ubuntu/trusty64` with 2GB ram.

Vagrant uses virtualbox to run the VM. Feel free to change configs in Vagrantfile. Run these commands to set up your vagrant environment (install brew first if you don't have it):

`brew cask install vagrant`

`brew cask install virtualbox`

`brew cask install vagrant-manager` (optional), helps you manage all your virtual machines in one place directly from the menubar.

After running these commands, just head over to a project with its `Vagrantfile` and run

    vagrant up
to start the VM. Your project and all local changes are shared on the VM's `/vagrant` folder, from where the VM Rails runs. I've configured the port forwarding to 8080 on `localhost` to avoid conflicts with other running rails apps, but you can change it to whatever  you want on the `Vagrantfile`.

Currently the provisioning is done from a shell file. It does the following:

- basics (curl, git, mysql)
- RVM and Ruby 2.2.0
- Bundler, Rails 4.2.1
- Redis (latest stable)

If you want to create your own [provisioning for the VM](https://docs.vagrantup.com/v2/provisioning/index.html), there are a number of ways - Chef, Puppet, and Docker to name a few.

`vagrant up` starts the vagrant VM.
you may have to do this a couple of times while dependencies etc get installed.

`vagrant ssh` logs you into the VM.
