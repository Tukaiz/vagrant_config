##General Vagrant environment setup instructions##

From the Vagrant page:

> Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.

 Every project can have its own standard VM, and it drastically speeds up the setup process for someone coming in fresh. Read more at the [vagrant webpage](https://www.vagrantup.com/).

These instructions will enable you to run a Vagrant VM for any project that has a `Vagrantfile`. Default config for this repo is `Ubuntu/trusty64` with 1GB ram.

Vagrant uses virtualbox to run the VM. Feel free to change configs in Vagrantfile. Run these commands to set up your vagrant environment (install brew first if you don't have it):

`brew cask install vagrant`

`brew cask install virtualbox`

`brew cask install vagrant-manager` (optional), helps you manage all your virtual machines in one place directly from the menubar.

After running these commands, just head over to a project with its `Vagrantfile` and run

    vagrant up
to start the VM. Your project's root folder and all local changes are shared on the VM's `/vagrant` folder, from where the VM Rails runs. I've configured the port forwarding to 300 on `localhost`, but you can change it to whatever  you want on the `Vagrantfile`.

If you want to create your own [provisioning for the VM](https://docs.vagrantup.com/v2/provisioning/index.html), there are a number of ways - Chef, Puppet, and Docker to name a few. Currently the provisioning is done from a humble shell file, which tries to replicate the target deployment server as closely as possible. It is configurable and does the following:

- basics (curl, git, mysql)
- Ruby (version varies by project)
- Bundler, Rails (version varies by project)
- Redis (latest stable, if needed)

`vagrant up` starts the vagrant VM.
you may have to do this a couple of times while dependencies etc get installed.

`vagrant ssh` logs you into the VM.

## Static (Pre-provisioned) boxes ##

There are certain projects that have been pre-provisioned due to difficutlies in their setup or the sheer age of the gems involved. Below are the list of boxes that have been pre-provisioned and do **not** need to be provisioned again. Look up documentation in Confluence for setup in each given project: 

- Elibrary
