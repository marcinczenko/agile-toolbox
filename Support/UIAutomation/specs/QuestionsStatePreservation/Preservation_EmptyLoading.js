#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Preservation", function() {

    var helpers = new EPHelpers();

    var scrollToCellName = 'Test Item29';

    // Expected cell name is different then 'ScrollTo' cell name.
    // This is because on iOS7 table view is visible under the navigation,
    // so even though the cell really visible to user is 'Test Item29'
    // UIAutomation reports cell 'TestItem31' as the first visible cell.
    var expectedFirstVisibleCellName = 'Test Item31';

    afterEach(function() {
        helpers.goBack();
    });

    it("correctly preserves the state when loading first set of questions", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        helpers.scrollToCellWithName('Questions',scrollToCellName);

        helpers.goBack();

        //helpers.target.delay(3);

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

