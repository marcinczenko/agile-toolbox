#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Refreshing", function() {

    var helpers = new EPHelpers();

    var expectedFirstVisibleCellName = 'Test Item38';
    var expectedLastVisibleCellName = 'Test Item0';

    afterEach(function() {
        helpers.goBack();
    });

    it('performs refresh action in QuestionsWithNoMoreToFetch state when no more data are available on the server', function() {

        helpers.enterQuestions(8);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(39);
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toEqual(expectedFirstVisibleCellName);

        helpers.scrollToLastCellInTableView('Questions');
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);

        helpers.scrollToFirstCellInTableView('Questions');
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toEqual(expectedFirstVisibleCellName);

        helpers.refreshTableView('Questions',1);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(39);
        helpers.scrollToLastCellInTableView('Questions');

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);

        helpers.target().delay(5);
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);

        helpers.scrollToFirstCellInTableView('Questions');
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toEqual(expectedFirstVisibleCellName);

        helpers.scrollToLastCellInTableView('Questions');
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);
    });

    it('uses a custom refresh indicator after re-entering the view', function() {

        helpers.enterQuestions(2);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(39);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);
        helpers.scrollToFirstCellInTableView('Questions');
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toEqual(expectedFirstVisibleCellName);

        helpers.refreshTableView('Questions',1);

        helpers.goBack();

        helpers.enterQuestions(2);

        // 39 cells + 1 for refresh indicator
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(40);

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toEqual('In progress');
        expect(helpers.getVisibleCellTextForTableViewAtIndex('Questions',1)).toEqual(expectedFirstVisibleCellName);

        helpers.scrollToLastCellInTableView('Questions');
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);

        helpers.target().delay(4);

        // refresh indicator should disappear after refresh operation finished
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(39);

        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);

        helpers.scrollToFirstCellInTableView('Questions');
        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toEqual(expectedFirstVisibleCellName);
        helpers.scrollToLastCellInTableView('Questions');
        expect(helpers.getLastVisibleCellTextForTableView('Questions')).toEqual(expectedLastVisibleCellName);

    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

