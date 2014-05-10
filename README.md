# A Virtual Machine for Ohana API Development

## Introduction

This project automates the setup of a development environment for working on Ohana API. Use this virtual machine to work on a pull request with everything ready to hack and run the test suites.

## Requirements

* [VirtualBox](https://www.virtualbox.org) or [VMWare Fusion](http://www.vmware.com/products/fusion)

* [Vagrant 1.1+](http://vagrantup.com) (not a Ruby gem)

## How To Build The Virtual Machine

Building the virtual machine is this easy:

    host $ git clone https://github.com/codeforamerica/ohana-api-dev-box.git
    host $ cd ohana-api-dev-box
    host $ vagrant up

That's it.

(If you want to use VMWare Fusion instead of VirtualBox, write `vagrant up --provider=vmware_fusion` instead of `vagrant up` when building the VM for the first time. After that, Vagrant will remember your provider choice, and you won't need to include the `provider` flag again.)

If the base box is not present, `vagrant up` fetches it first. The virtual machine setup itself takes about 2 minutes and 15 seconds on my MacBook Air. After the installation has finished, you can access the virtual machine with

    host $ vagrant ssh
    Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic-pae i686)
    ...
    vagrant@ohana-api-dev-box:~$

Port 8080 in the host computer is forwarded to port 8080 in the virtual machine. Thus, applications running in the virtual machine can be accessed via localhost:8080 in the host computer.

## What's In The Box

* Git

* RVM

* Ruby 2.1.1 (binary RVM install)

* Bundler

* Postgres

* System dependencies for nokogiri and pg

* Databases and users needed to run the test suite

* Node.js for the asset pipeline

* Redis

* Elasticsearch 1.0.1


## Recommended Workflow

The recommended workflow is

* edit in the host computer (i.e. your physical computer)

and

* test within the virtual machine.

### Set up the project

Just clone your ohana-api fork into the ohana-api-dev-box directory on the host computer:

    host $ ls
    README.md   Vagrantfile puppet
    host $ git clone git@github.com:<your username>/ohana-api.git
    
Alternately, if you run into permission errors on a Windows machine, use

    host $ git clone https://github.com/<your username>/ohana-api.git
    

Vagrant mounts that directory as _/vagrant_ within the virtual machine:

    vagrant@ohana-api-dev-box:~$ ls /vagrant
    puppet  ohana-api  README.md  Vagrantfile

We are ready to go to edit in the host, and test in the virtual machine.

This workflow is convenient because in the host computer you normally have your editor of choice fine-tuned, Git configured, and SSH keys in place.

### Configure the database

In the `ohana-api` directory, you will find a file within the `config` directory called `database.vagrant.yml`. On the host machine, rename it to `database.yml`, deleting the `database.yml` file that already exists.

### Bootstrap the ohana-api project in the virtual machine:

    vagrant@ohana-api-dev-box:~$ cd /vagrant/ohana-api
    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ script/bootstrap

This step takes about 7 minutes, mostly because it takes a while to install all the gems. Nokogiri is notorious for holding up the bundle process.

On Windows machines, you may run into errors when trying to run `script/boostrap`; if there is a `^M` in the error message it is due to the character Windows uses for line endings. An easy way to fix this is with Sublime Text: open `bootstrap` in  Sublime Text, and from the "View" menu select Line Endings > Unix.

If line endings in Windows were a problem for `script/bootstrap`, you will also have to fix the line endings in these files:

    script/setup_db
    script/tire
    script/users
    
as well as any others that throw the same error.

### Set up the environment variables

Inside the `config` folder, you will find a file named `application.example.yml`. Rename it to `application.yml` and double check that it is in your `.gitignore` file (it should be by default).

In `config/application.yml`, set the following environment variables so that the tests can pass, and so you can run the [Ohana API Admin](https://github.com/codeforamerica/ohana-api-admin) app locally:

    API_BASE_URL: http://localhost:8080/api/
    API_BASE_HOST: http://localhost:8080/
    ADMIN_APP_TOKEN: your_token

Verify that you can launch the app:

    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ rails s -p 8080

You should now be able to access the app on the host machine at
http://localhost:8080

### Verify the app is returning JSON
To see all locations, 30 per page:

    http://localhost:8080/api/locations

To go the next page (the page parameter works for all API responses):

    http://localhost:8080/api/locations?page=2

Note that the sample dataset has less than 30 locations, so the second page will be empty.

Search for organizations by keyword and/or location:

    http://localhost:8080/api/search?keyword=food
    http://localhost:8080/api/search?keyword=counseling&location=94403
    http://localhost:8080/api/search?location=redwood city, ca

Search for organizations by languages spoken at the location:

    http://localhost:8080/api/search?keyword=food&language=spanish

The language parameter can be used alone:

    http://localhost:8080/api/search?language=tagalog

### Test the app

Run tests in the virtual machine with this simple command:

    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ rspec

If you've just pulled changes from the upstream repo, you might need to update your test database first to run any pending migrations:

    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ script/test

## Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

    host $ vagrant suspend

then, resume to hack again

    host $ vagrant resume

Run

    host $ vagrant halt

to shutdown the virtual machine, and

    host $ vagrant up

to boot it again.

You can find out the state of a virtual machine anytime by invoking

    host $ vagrant status

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

    host $ vagrant destroy # DANGER: all is gone

Please check the [Vagrant documentation](http://docs.vagrantup.com/v2/) for more information on Vagrant.

## Faster test suites

The default mechanism for sharing folders is convenient and works out the box in
all Vagrant versions, but there are a couple of alternatives that are more
performant.

### rsync

Vagrant 1.5 implements a [sharing mechanism based on rsync](https://www.vagrantup.com/blog/feature-preview-vagrant-1-5-rsync.html)
that dramatically improves read/write because files are actually stored in the
guest. Just throw

    config.vm.synced_folder '.', '/vagrant', type: 'rsync'

to the _Vagrantfile_ and either rsync manually with

    vagrant rsync

or run

    vagrant rsync-auto

for automatic syncs. See the post linked above for details.

### NFS

If you're using Mac OS X or Linux you can increase the speed of the test suite with Vagrant's NFS synced folders.

With an NFS server installed (already installed on Mac OS X), add the following to the Vagrantfile:

    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
    config.vm.network 'private_network', ip: '192.168.50.4' # ensure this is available

Then

    host $ vagrant up

Please check the Vagrant documentation on [NFS synced folders](http://docs.vagrantup.com/v2/synced-folders/nfs.html) for more information.

## License

Copyright (c) 2014–<i>ω</i> Code for America. See [LICENSE](https://github.com/codeforamerica/ohana-api-dev-box/blob/master/LICENSE.md) for details.
