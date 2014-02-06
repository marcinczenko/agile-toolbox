#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Preservation", function() {

    var helpers = new EPHelpers();

    var expectedFirstVisibleCellName = 'Test Item21';

    afterEach(function() {
        helpers.goBack();
    });

    it("correctly preserves the state when loading questions", function() {

        helpers.enterQuestions();

        helpers.goBack(4);
        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(41);

        helpers.fetchMore(41);

        helpers.goBack(4);
        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);
        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);

        helpers.scrollToCellWithName('Questions','Test Item0');
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(50);

        // after scrolling down the first visible items is different now
        expectedFirstVisibleCellName = 'Test Item12';
        expect(helpers.getVisibleCellTextForTableViewAtIndex("Questions",0)).toEqual(expectedFirstVisibleCellName);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

