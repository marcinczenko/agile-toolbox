
describe("Walking Skeleton", function() {

    var target = UIATarget.localTarget();
    var mainWindow = target.frontMostApp().mainWindow();
    
    function getLabel() {
        return target.frontMostApp().mainWindow().staticTexts()[0].value();
    }
    
    afterEach(function() {
        target.frontMostApp().navigationBar().leftButton().tap();
    });

    it("shows text items available on the server", function() {
    
        mainWindow.tableViews()["MenuList"].cells()["Q&A"].tap();
        
        //mainWindow.logElementTree();
        
        //UIALogger.logMessage(mainWindow.tableViews()["QuestionList"].checkIsValid().toString());
        
        expect(mainWindow.tableViews()["QuestionList"].checkIsValid()).toBe(true);
        
        expect(mainWindow.tableViews()["QuestionList"].cells().length).toEqual(0);
    });
});
