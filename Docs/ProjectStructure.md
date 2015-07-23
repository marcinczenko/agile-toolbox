# Project Structure

The iPhone app depends on the backend module for its data. In order to facilitate testing, the AgileToolbox project provides a _mock_ of the actual backend, that can be run locally and easily configured to support different testing scenarios.

_AgileToolbox_ and _Library_ targets is where the actual code is. There are accompanying tests targets: _LibraryTests_ and _AgileToolboxTests_. The _IntegrationTests_ is a target where some communication patterns can be tested - it is like a sandbox or a playground where you can play with the code in a comfortable environment without touching the production code. As such, the IntegrationTests target is not meant for continuous integration. The remaining targets are.

_Acceptance Tests_ are run using a combination of _Xcode UIAutomation Instrument_, _Jasmine JavaScript_ testing framework and _Cucumber_, which is used as a wrapping execution engine for the whole, but this role has potential to be elevated if needed. _Acceptance Tests_ can use as a backend the above mentioned mock of the _Google App Engine_ web app, the actual Google App Engine development server, and even the actual deployed Google App Engine app.

The testing infrastructure can be found in the `Support` folder. There is a folder `AcceptanceTests` where cucumber test scenarios are. The above mentioned mock of the Google App Engine backend is in the `GoogleAppEngineAppMock` folder. The `UIAutomation` folder contains the _UIAutomation Instrument_ specs written in _Jasmine JavaScript_ testing framework. It uses _Jasmine_ as a submodule and the actual JavaScript specs are inside the `specs` folder.

I also included _IntelliJ_ project with modules for Acceptance Tests, Google App Engine App Mock, and UIAutomation. You can open IntelliJ project rooted from the top level `AgileToolbox` directory.

The testing infrastructure grows with the project needs. The level of quality is keept at the just-enough level. When one or other functionality causes troubles, more testing efforts are being applied in the problematic area. The level of testing at the unit-level is balanced by conventions and patterns. In other words, when a good convention, or well understood pattern becomes declarative enough it may allow you to (at least temporarily) lower testing-efforts. Similarly, quality architecture attributes may be the subject to continuous improvement as well (not described nor used in the demo).
