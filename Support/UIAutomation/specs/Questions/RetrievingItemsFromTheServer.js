#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions", function() {

    var helpers = new EPHelpers();
    
    afterEach(function() {
        helpers.goBack();
    });

    it("shows text items available on the server", function() {
    
        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(5);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
