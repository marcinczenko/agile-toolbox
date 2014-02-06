#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Preservation", function() {

    var helpers = new EPHelpers();

    var scrollToCellName = 'Test Item0';

    // Expected cell name is different then 'ScrollTo' cell name.
    // This is because on iOS7 table view is visible under the navigation,
    // so even though the cell really visible to user is 'Test Item29'
    // UIAutomation reports cell 'TestItem31' as the first visible cell.
    var expectedFirstVisibleCellName = 'Test Item12';

    afterEach(function() {
        helpers.goBack();
    });

    it("correctly preserves the state when loading questions", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        helpers.fetchMore(41);

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);

        helpers.scrollToCellWithName('Questions',scrollToCellName);

        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);

//        UIALogger.logMessage("CellText="+helpers.getVisibleCellTextForTableViewAtIndex("Questions",0));

        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

