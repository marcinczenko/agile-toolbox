#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"


describe("Walking Skeleton", function() {

    var target = UIATarget.localTarget();
    var mainWindow = target.frontMostApp().mainWindow();

    afterEach(function() {
        goBack();
    });

    var goBack = function() {
        target.frontMostApp().navigationBar().leftButton().tap();
    };

    var enterQuestions = function(){
        mainWindow.tableViews()["MenuList"].cells()["Q&A"].tap();
        target.delay(2);
    };

    var checkThereIsACorrectNumberOfRowsInTheTableView = function(expectNumberOfRows){
        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);

        var numberOfCells = mainWindow.tableViews()["Questions"].cells().length;
        expect(numberOfCells).toEqual(expectNumberOfRows);
    };

    it("re-entering the questions list does not trigger fetch", function() {

        enterQuestions();
        // we have 40 questions on a page + one cell for "Fetch More".
        checkThereIsACorrectNumberOfRowsInTheTableView(41);
        goBack();

        enterQuestions();
        checkThereIsACorrectNumberOfRowsInTheTableView(41);
        goBack();

        enterQuestions();
        checkThereIsACorrectNumberOfRowsInTheTableView(41);
        //goBack();
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
