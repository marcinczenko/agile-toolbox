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

        helpers.refreshTableView('Questions',1);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

        helpers.target().delay(5);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

    });

    it('uses a custom refresh indicator after re-entering the view', function() {

        helpers.enterQuestions(2);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);

        helpers.refreshTableView('Questions',1);

        helpers.goBack();

        helpers.enterQuestions(2);

        // 5 cells + 1 for refresh indicator
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(4);

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain('In progress');
        expect(helpers.getVisibleCellTextForTableViewAtIndex('Questions',1)).toContain(expectedFirstVisibleCellName);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);

        helpers.target().delay(3);

        // refresh indicator should disappear after refresh operation finished
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(3);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toContain(expectedLastVisibleCellName);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);

    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

