#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"


describe("Walking Skeleton", function() {

    var target = UIATarget.localTarget();
    var mainWindow = target.frontMostApp().mainWindow();

    function getLabel() {
        return target.frontMostApp().mainWindow().staticTexts()[0].value();
    }

    afterEach(function() {
        target.frontMostApp().navigationBar().leftButton().tap();
    });

    // fetchMore works as follows: it first scroll far enough (but not to far) so that the following call to
    // scrollDown() pushes the tableview beyond the last row triggering the 'fetch more' operation.
    // I could not achieve the same effect any other way. The numbers chosen are purely experimental.
    function fetchMore(numberOfCellsInTableView) {
        mainWindow.tableViews()["Questions"].cells()[numberOfCellsInTableView-14].scrollToVisible();

        cell = mainWindow.tableViews()["Questions"].cells()[numberOfCellsInTableView-14];

        target.delay(1);

        mainWindow.tableViews()["Questions"].scrollDown();

        target.delay(1.5);
    }

    it("fetches 81 questions in four fetch operations (40+40+1+0) from the server", function() {

        mainWindow.tableViews()["MenuList"].cells()["Q&A"].tap();

        target.delay(2);

        UIALogger.logMessage(mainWindow.tableViews()["Questions"].checkIsValid().toString());

        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);

        // we have 40 questions on a page + one cell for "Fetch More".
        numberOfCells = mainWindow.tableViews()["Questions"].cells().length;
        expect(numberOfCells).toEqual(41);

        fetchMore(numberOfCells);

        // After fetching next page we should have 80 questions in the TableView + one cell for "Fetch More".
        numberOfCells = mainWindow.tableViews()["Questions"].cells().length;
        expect(numberOfCells).toEqual(81);

        fetchMore(numberOfCells);

        // This last 'fetchMore' brings back only one new question - this is less than a page which means that
        // all questions were fetched from the server - therefore the 'Fetch More' cell will no longer
        // be shown and the total number of cells should be 81 (which exactly the number of questions available.
        numberOfCells = mainWindow.tableViews()["Questions"].cells().length;
        expect(numberOfCells).toEqual(81);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
