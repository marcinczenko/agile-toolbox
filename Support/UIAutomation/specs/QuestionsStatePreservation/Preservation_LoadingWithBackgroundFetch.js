#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Preservation", function() {

    var helpers = new EPHelpers();

    var expectedFirstVisibleCellName = 'Content for question 14';

    afterEach(function() {
        helpers.goBack();
    });

    it("correctly preserves the state when loading questions in background", function() {

        helpers.enterQuestions();

        helpers.goBack(4);
        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        helpers.fetchMoreInTableView('Questions');

        helpers.goBack(4);
        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);

        helpers.scrollToLastCellInTableView('Questions');
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);

        // after scrolling down the first visible items is different now
        expectedFirstVisibleCellName = 'Content for question 5';
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

