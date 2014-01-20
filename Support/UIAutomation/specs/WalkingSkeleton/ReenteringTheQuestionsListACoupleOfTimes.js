#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Walking Skeleton", function() {

    var helpers = new EPHelpers();

    afterEach(function() {
        helpers.goBack();
    });

    it("re-entering the questions list does not trigger fetch", function() {

        helpers.enterQuestions();
        // we have 40 questions on a page + one cell for "Fetch More".
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);
        helpers.goBack();

        helpers.enterQuestions();
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);
        helpers.goBack();

        helpers.enterQuestions();
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
