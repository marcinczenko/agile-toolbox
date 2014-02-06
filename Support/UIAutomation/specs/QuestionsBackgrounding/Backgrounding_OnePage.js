#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Backgrounding", function() {

    var helpers = new EPHelpers();

    var expectedFirstVisibleCellName = 'Test Item12';

    afterEach(function() {
        helpers.goBack();
    });

    it("performs background fetch operation when server has exactly one page of questions available", function() {

        helpers.enterQuestions();

        helpers.enterBackgroundForDuration(4);

        // we should have 40 questions cells and one fetch more cell after coming back from background mode
        var expected_number_of_questions = 41;
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(expected_number_of_questions);

        expect(helpers.getCellTextForTableViewAtIndex("Questions",expected_number_of_questions-1)).toEqual("Pull up to download more questions.");

        helpers.fetchMore(expected_number_of_questions);

        helpers.enterBackgroundForDuration(4);

        expected_number_of_questions = 40;
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(expected_number_of_questions);

        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(40);

        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

