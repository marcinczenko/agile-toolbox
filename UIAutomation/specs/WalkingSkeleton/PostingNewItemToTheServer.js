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

    it("posts the new item to the server", function() {
        
        mainWindow.tableViews()["MenuList"].cells()["Q&A"].tap();
        
        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);
        expect(mainWindow.tableViews()["Questions"].cells().length).toEqual(5);
        
        target.frontMostApp().navigationBar().buttons()["Add"].tap();
        mainWindow.textFields()["NewQuestionTextField"].tap();
        target.frontMostApp().keyboard().typeString("New Question");
        target.frontMostApp().navigationBar().buttons()["Done"].tap();
        
	    target.delay(1);
	   
        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);
        expect(mainWindow.tableViews()["Questions"].cells().length).toEqual(6);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
