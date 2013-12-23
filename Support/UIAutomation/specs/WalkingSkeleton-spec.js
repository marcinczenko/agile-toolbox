
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
        
        mainWindow.logElementTree();
        
        UIALogger.logMessage(mainWindow.tableViews()["Questions"].checkIsValid().toString());
        
        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);
        
        expect(mainWindow.tableViews()["Questions"].cells().length).toEqual(5);
    });
});
