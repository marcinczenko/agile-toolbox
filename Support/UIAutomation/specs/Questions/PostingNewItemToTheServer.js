#import "../../jasmine-uiautomation.js"
#import "../../jasmine/lib/jasmine-core/jasmine.js"
#import "../../jasmine-uiautomation-reporter.js"


describe("Questions", function() {

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
        
        // It seems that the names of the key,change depending on the status of the shift button.
        // If shift is enabled then the key is called 'N',if shift is not enabled then it's 'n'.
        // You'll notice as a string is being typed,that the shift button is tapped before an uppercase
        // letter is typed.Your test is attempting to press the 'N' key before the 'Shift' button has been
        // pressed.It doesn't affect the first letter of your sentence because the keyboard has shift
        // enabled for the first letter.
        //
        // This also affects typing a lowercase character after an uppercase character:the lowercase
        // character may be typed whilst the shift button is in the process of being unpressed.
        //
        // I use a workaround of typing each letter of the string with separate typeString() methods.
        // See http://stackoverflow.com/questions/10549046/target-frontmostapp-keyboard-failed-to-locate-key-n
        target.frontMostApp().keyboard().typeString("N");
        target.frontMostApp().keyboard().typeString("ew Q");
        target.frontMostApp().keyboard().typeString("uestion");
        
        target.frontMostApp().navigationBar().buttons()["Done"].tap();
        
	    target.delay(1);
	   
        expect(mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);
        expect(mainWindow.tableViews()["Questions"].cells().length).toEqual(6);
    });
});

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
