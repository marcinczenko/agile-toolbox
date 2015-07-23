# Installing virtualenv and virtualenvwrapper

_virtualenv_ and _virtualenvwrapper_ are two great utilities to easy the management of the Python environments.

## python

In the steps below I used the default Python interpreter shipped with MAC OS X. In my case it was:

    $ python --version
    Python 2.7.6

## pip

First, we need to install _pip_. 

> Python 2.7.9 and later (on the python2 series), and Python 3.4 and later include pip by default, so you may have pip already.

If you do not have pip then:

    $ curl -O https://bootstrap.pypa.io/get-pip.py
    $ [sudo] python get-pip.py
    
    # if you just want to upgrade setuptools this will do it.
    $ [sudo] pip install -U setuptools

For details consult http://pip.readthedocs.org/en/latest/installing.html. In my installation I installed pip globally so I used sudo above.

pip should be now installed:

    $ pip --version
    pip 1.5.6 from /Library/Python/2.7/site-packages (python 2.7)

## Installing virtualenv

> The instructions below will become outdated - sooner or later. 
Please follow the instructions on [virtualenv] and [virtualenvwrapper] for the up-to-date installation instructions.

    $ [sudo] pip install virtualenv

The version of virtualenv I used in the project was 1.11.4.

## Installing virtualenvwrapper

    $ sudo pip install virtualenvwrapper

The version of virtualenvwrapper I used was 4.2.

## Shell Startup File

I've added the following to my `~/.bash_profile`:

    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/.virtualenvs_projects
    source /usr/local/bin/virtualenvwrapper.sh

Above, you can use different _projects_ path.

## Creating a new environment

    # workon returns an empty list
    $ workon
    $ mkvirtualenv agiletoolbox
    New python executable in agiletoolbox/bin/python
    Installing setuptools............done.
    Installing pip...............done.
    (agiletoolbox)$ workon
    agiletoolbox

## Returning to the system-installed version of Python

    deactivate

[virtualenv]: https://virtualenv.pypa.io/en/latest/installation.html
[virtualenvwrapper]: http://virtualenvwrapper.readthedocs.org/en/latest/install.html
