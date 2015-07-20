# ep-demo

The _AgileToolbox_ demonstration project consists of a _Q&A_ module. The Q&A module allows an iPhone user to post a question. After being accepted and/or refined the question can be published and will become available to all iPhone users. Anyone can post a question without being required to set up an account. Only the app owner representative can publish the question, possibly after changing its contents.
The Q&A module uses the iPhone App (AgileToolbox) as a user front-end, and a headless backend built on Google App Engine (WebApp). Additionally, to enable moderation, there is a small control panel built using HTML5/JavaScript. Access to the control panel is restricted to Google Accounts in everydayproductive.com domain. For the purpose of the demonstration I created a user account: ep-demo@everydayproductive.com with password: `ep-demo-01`. You will find more information on using the moderation panel in Section [Using Moderation Panel].

Documentation is divided across the functionality. You will find relevant documents for the [iPhone App] and the [DemoWebApp].
The project demonstrates the use of asynchronous communication with an external service, scalable implementation of a slightly more complex state machine in the view controller, the use of Core Data, extended state preservation (I take advantage of the native iOS7 state preservation, but I also store extra data to persistent state for better user experience), dynamic types, Apple Mail-like composing view, interaction with Google App Engine, and small demonstration-only control panel based on Twitter Bootstrap and Java Script. Moreover, you will find a lot about testing in this project using Cucumber, UIAutomation, Jasmine, and Ruby scripting.

>The documentation included should get you started. Please feel free to contact me, when something is hard to understand or does not work as expected.

To get started, begin with [Quick Start].

> This project is quite old now (about 1 year), but it still may serve as a handy reference. Some of its parts may be updated to a more recent version of iOS SDK in the future.

[Using Moderation Panel]: Docs/UsingModerationPanel.md
[iPhone App]: Docs/iPhoneApp.md
[DemoWebApp]: Docs/DemoWebApp.md
[Quick Start]: Docs/QuickStart.md
