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

    it("fetches first page from the server", function() {
    
        mainWindow.tableViews()["MenuList"].cells()["Q&A"].tap();
        
        mainWindow.logElementTree();
        
        UIALogger.logMessage(mainWindow.tableViews()["Questions"].checkIsValid().toString());
        
        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);
        
        expect(mainWindow.tableViews()["Questions"].cells().length).toEqual(40);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
