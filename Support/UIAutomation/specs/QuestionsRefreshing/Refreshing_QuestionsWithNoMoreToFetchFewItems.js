#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Refreshing", function() {

    var helpers = new EPHelpers();

    var expectedFirstVisibleCellName = 'Content for question 2';
    var expectedLastVisibleCellName = 'Content for question 0';

    afterEach(function() {
        helpers.goBack();
    });

    it('performs refresh action in QuestionsWithNoMoreToFetch state with just a few items when no more data are available on the server', function() {

        helpers.enterQuestions(8);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

        helpers.refreshTableView('Questions');

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

        helpers.target().delay(5);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

    });

    it('shows refresh indicator after re-entering the view and performing refresh action', function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);

        helpers.refreshTableView('Questions');

        helpers.goBack();

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

        helpers.target().delay(3);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);

    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

