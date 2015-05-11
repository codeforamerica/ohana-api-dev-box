# A Virtual Machine for Ohana API Development

## Introduction
This project automates the setup of a development environment for working on Ohana API. Use this virtual machine to work on a pull request with everything ready to hack and run the test suites.

## Windows installation
* [Follow the Windows Installation Guide wiki page](https://github.com/codeforamerica/ohana-api-dev-box/wiki/Ohana-API-virtual-machine-installation-guide-for-Windows).

## Mac OSX installation
* Follow the directions below...

### Requirements
* [VirtualBox](https://www.virtualbox.org)

* [Vagrant 1.1+](http://vagrantup.com) (not a Ruby gem)

### How To Build The Virtual Machine
1. **Install VirtualBox for OS X**, which can be [downloaded](https://www.virtualbox.org/wiki/Downloads) from the VirtualBox site.

2. **Install Vagrant**, which can be [downloaded](http://www.vagrantup.com/downloads.html) from the Vagrant site, which also provides [step-by-step installation instructions](http://docs.vagrantup.com/v2/getting-started/index.html).

3. **Build the VM**

  In the directory you want to work in, enter the following:

  ```
  $ git clone https://github.com/codeforamerica/ohana-api-dev-box
  $ cd ohana-api-dev-box
  $ vagrant up
  ```

If the base box is not present, `vagrant up` fetches it first.

After the installation has finished (it can take several minutes), you can access the virtual machine with the following command:

    host $ vagrant ssh
    Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic-pae i686)
    ...
    vagrant@ohana-api-dev-box:~$

`host $` refers to the command prompt on your computer's OS, as opposed to the prompt in the virtual machine.

Port 8080 in the host computer is forwarded to port 8080 in the virtual machine. Thus, applications running in the virtual machine can be accessed via localhost:8080 in the host computer.

### What's In The Box
* Git

* RVM

* Ruby 2.2.1 (binary RVM install)

* Bundler

* Postgres

* System dependencies for nokogiri and pg

* Databases and users needed to run the test suite

* Node.js for the asset pipeline

* PhantomJS

### Recommended Workflow
The recommended workflow is

* edit in the host computer (i.e. your physical computer)

and

* test within the virtual machine.

This workflow is convenient because in the host computer you normally have your editor of choice fine-tuned, Git configured, and SSH keys in place.

### Set up the project
Clone your ohana-api fork into the ohana-api-dev-box directory on the host computer:

    host $ ls
    LICENSE.md  README.md  Vagrantfile  bootstrap.sh
    host $ git clone https://github.com/<your GitHub username>/ohana-api.git

#### Bootstrap the ohana-api project in the virtual machine:

    host $ vagrant ssh
    vagrant@ohana-api-dev-box:~$ cd /vagrant/ohana-api
    vagrant@ohana-api-dev-box:~$ cp config/database.vagrant.yml config/database.yml
    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ bin/setup

This step can take several minutes, mostly because it takes a while to install all the gems.

Verify that you can launch the app:

    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ puma -p 8080

You should now be able to access the app on the host machine at
http://localhost:8080

#### Verify the app is returning JSON
To see all locations, 30 per page:

    http://localhost:8080/api/locations

Search for locations by keyword and/or location:

    http://localhost:8080/api/search?keyword=food
    http://localhost:8080/api/search?keyword=counseling&location=94403
    http://localhost:8080/api/search?location=redwood city, ca

Search for locations by languages spoken:

    http://localhost:8080/api/search?language=spanish

#### Test the app

Run tests in the virtual machine with this simple command:

    vagrant@ohana-api-dev-box:/vagrant/ohana-api$ script/test

## Virtual Machine Management

When done just log out with `^D` (or `logout`) and suspend the virtual machine

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

The default mechanism for sharing folders is convenient and works out of the
box in all Vagrant versions, but there are a couple of alternatives that are
more performant.

### rsync

Vagrant implements a sharing mechanism based on rsync that dramatically
improves read/write because files are actually stored in the guest.

1. In a text editor, open `Vagrantfile`, which can be found in the root of
the `ohana-api-dev-box` directory you cloned earlier.

2. Uncomment line 28 and save the file.

#### Restart the virtual machine
1. If you're already logged in to the VM, stop the Rails server if it's
running by pressing ctrl-c. Then press ctrl-d to log out.

2. Halt and launch the VM with rsync
 ```
 vagrant halt
 vagrant up
 vagrant rsync-auto
 ```

3. Log in to the VM in a new Shell window or tab:
 ```
 vagrant ssh
 ```

4. Launch Ohana API
 ```
 vagrant@ohana-api-dev-box:~$ cd /vagrant/ohana-api
 vagrant@ohana-api-dev-box:/vagrant/ohana-api$ puma -p 8080
 ```

### NFS

If you're using Mac OS X or Linux you can increase the speed of the test suite with Vagrant's NFS synced folders.

With an NFS server installed (already installed on Mac OS X), uncomment line
28 of the Vagrantfile (which can be found in the root  of the
`ohana-api-dev-box` directory you cloned earlier) and replace `type: 'rsync'`
with `type: 'nfs'`.

You'll also need to configure a private network using either DHCP or a static IP.
Please read the Vagrant documentation on [private networks](http://docs.vagrantup.com/v2/networking/private_network.html) and [NFS synced folders](http://docs.vagrantup.com/v2/synced-folders/nfs.html) for more information.

## License

Copyright (c) 2014–<i>ω</i> Code for America. See [LICENSE](https://github.com/codeforamerica/ohana-api-dev-box/blob/master/LICENSE.md) for details.
