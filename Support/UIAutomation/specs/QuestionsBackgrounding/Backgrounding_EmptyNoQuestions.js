#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"
#import "../../helpers/general_helpers.js"


describe("Questions Backgrounding", function() {

    var helpers = new EPHelpers();

    afterEach(function() {
        helpers.goBack();
    });

    it("performs background fetch operation when serves returns an empty set", function() {

        helpers.enterQuestions();

        helpers.enterBackgroundForDuration(4);

        // one cell with "No questions on the server" should be visible
        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(1);

        UIALogger.logMessage("CellText="+helpers.getCellTextForTableViewAtIndex("Questions",0));

        expect(helpers.getCellTextForTableViewAtIndex("Questions",0)).toEqual("No questions on the server");

        helpers.mainWindow().logElementTree();
    });

    it("displays the same set of questions when re-entering questions section", function() {

        helpers.enterQuestions();

        helpers.checkThereIsACorrectNumberOfRowsInTheTableView(1);

        expect(helpers.getCellTextForTableViewAtIndex("Questions",0)).toEqual("No questions on the server");
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

