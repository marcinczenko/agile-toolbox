# Quick Start

> I am using Homebrew as the package manager on my Mac. If any of the steps below fail, it may just be the case you miss something on your Mac. Here are the list of packages I have on my Mac:
> 
    $ brew list
    apple-gcc42 cmake           libpng      libxslt     mysql  pkg-config  sqlite
    autoconf    libgpg-error    libtool     libyaml     openssl     qt
    automake    libksba         libxml2     mongodb     phantomjs   readline
>
Please consult the [Homebrew documentation] for more details about Homebrew.

Please follow the following steps:

1. Create a folder `ep_demo`.
2. Clone `AgileToolbox` iPhone app into this directory:
    
        git clone git@github.com:mczenko/agile-toolbox.git

3. Clone `DemoWebApp` Google App Engine backend into `ep_demo` folder.  

    > At this point you should have two folders inside `ep_demo` folder: `agile-toolbox` and `agile-toolbox-backend`.

4. Open the Xcode workspace in AgileToolbox/AgileToolbox.xcworkspace. Select iPhone 5 as the simulator and UnitTests as the scheme. Run the tests. They should all pass. If they do not, consult [Good to know] section or contact me if this does not help. 
5. Learn how to use `virtualenv` and `virtualenvwrapper`. Read section [Installing virtualenv and virtualenvwrapper].
6. Follow instructions in [Setting up the development environment for iPhone App].
7. Follow instructions in [Setting up the development environment for AgileToolboxBackend].
8. Read [Good to know] in case of troubles or to understand how to change the defaults.
9. Browse the remaining parts of the documentation to get more insights about the project. 

[Homebrew documentation]: http://brew.sh/

[Good to know]: GoodToKnow.md

[Installing virtualenv and virtualenvwrapper]: InstallingVirtualenvAndVirtualenvwrapper.md

[Setting up the development environment for iPhone App]: SettingUpTheDevelopmentEnvironmentForiPhoneApp.md

[Setting up the development environment for AgileToolboxBackend]: SettingUpTheDevelopmentEnvironmentForAgileToolboxBackend.md