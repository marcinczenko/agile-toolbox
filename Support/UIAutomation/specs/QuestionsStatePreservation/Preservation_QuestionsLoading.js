#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Preservation", function() {

    var helpers = new EPHelpers();

    // Expected cell name is different then indicated by 'ScrollTo' cell index.
    // This is because on iOS7 table view is visible under the navigation,
    // so even though the cell really visible to user is 'Test Item4'
    // UIAutomation reports cell 'TestItem5' as the first visible cell.
    var expectedFirstVisibleCellName = 'Content for question 5';

    afterEach(function() {
        helpers.goBack();
    });

    it("correctly preserves the state when loading questions", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        helpers.fetchMoreInTableView('Questions');

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);

        helpers.scrollToLastCellInTableView('Questions');

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);

//        UIALogger.logMessage("CellText="+helpers.getVisibleCellTextForTableViewAtIndex("Questions",0));

        expect(helpers.getFirstVisibleCellTextForTableView('Questions')).toContain(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

