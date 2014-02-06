#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions", function() {

    var helpers = new EPHelpers();

    afterEach(function() {
        helpers.goBack();
    });

    it("fetches 81 questions in four fetch operations (40+40+1+0) from the server", function() {

        helpers.enterQuestions();

        // we have 40 questions on a page + one cell for "Fetch More".
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        helpers.fetchMore(41);

        // After fetching next page we should have 80 questions in the TableView + one cell for "Fetch More".
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(81);

        helpers.fetchMore(81);

        // This last 'fetchMore' brings back only one new question - this is less than a page which means that
        // all questions were fetched from the server - therefore the 'Fetch More' cell will no longer
        // be shown and the total number of cells should be 81 (which exactly the number of questions available.
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(81);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
