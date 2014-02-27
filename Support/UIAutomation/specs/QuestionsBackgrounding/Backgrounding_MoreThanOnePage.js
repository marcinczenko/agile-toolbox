#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Backgrounding", function() {

    var helpers = new EPHelpers();

    var expectedFirstVisibleCellName = 'Content for question 9';

    afterEach(function() {
        helpers.goBack();
    });

    it("performs background fetch operation when server has more than one page of questions available", function() {

        helpers.enterQuestions();

        helpers.enterBackgroundForDuration(4);

        // we should have 40 questions cells and one fetch more cell after coming back from background mode
        var expected_number_of_questions = 41;
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(expected_number_of_questions);

        expect(helpers.getCellTextForLastElementInTableView('Questions')).toContain("Pull up to download more questions.");

        helpers.fetchMoreInTableView('Questions');

        helpers.enterBackgroundForDuration(4);

        // we should have 45 question cells and no "Fetch More" cells on the screen
        expected_number_of_questions = 45;
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(expected_number_of_questions);

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(45);

        expect(helpers.getFirstVisibleCellTextForTableView("Questions")).toContain(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

