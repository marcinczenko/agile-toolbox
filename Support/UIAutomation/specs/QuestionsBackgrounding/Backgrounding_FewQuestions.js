#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Backgrounding", function() {

    var helpers = new EPHelpers();

    afterEach(function() {
        helpers.goBack();
    });

    it("performs background fetch operation when server returns just a few questions (less than fit in one screen)", function() {

        helpers.enterQuestions(1);

        helpers.enterBackgroundForDuration(4);

        // we should have 3 questions and no fetch more cell after coming back from background mode
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

