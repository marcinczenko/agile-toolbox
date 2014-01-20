#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Walking Skeleton", function() {

    var helpers = new EPHelpers();
    var target = UIATarget.localTarget();
    var mainWindow = target.frontMostApp().mainWindow();
    
    afterEach(function() {
        helpers.goBack();
    });

    it("fetches first page from the server", function() {
    
        helpers.enterQuestions();
        
        mainWindow.logElementTree();
        UIALogger.logMessage(mainWindow.tableViews()["Questions"].checkIsValid().toString());

        // we expect to have 40 items per page + one more row for "Fetch More" operation.
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
