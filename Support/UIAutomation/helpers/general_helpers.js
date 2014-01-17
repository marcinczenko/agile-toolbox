
var EPHelpers = (function() {

    function EPHelpers() {
        this.target = UIATarget.localTarget();
        this.mainWindow = this.target.frontMostApp().mainWindow();
    }

    EPHelpers.prototype.goBack = function() {
        this.target.frontMostApp().navigationBar().leftButton().tap();
    };

    EPHelpers.prototype.enterQuestions = function() {
        this.mainWindow.tableViews()["MenuList"].cells()["Q&A"].tap();
        this.target.delay(2);
    };

    // fetchMore works as follows: it first scroll far enough (but not to far) so that the following call to
    // scrollDown() pushes the tableview beyond the last row triggering the 'fetch more' operation.
    // I could not achieve the same effect any other way. The numbers chosen are purely experimental.
    EPHelpers.prototype.fetchMore = function(numberOfCellsInTableView) {
        this.mainWindow.tableViews()["Questions"].cells()[numberOfCellsInTableView-14].scrollToVisible();

        var cell = this.mainWindow.tableViews()["Questions"].cells()[numberOfCellsInTableView-14];

        this.target.delay(1);

        this.mainWindow.tableViews()["Questions"].scrollDown();

        this.target.delay(1.5);
    };

    EPHelpers.prototype.checkThereIsACorrectNumberOfRowsInTheTableView = function(expectNumberOfRows){
        expect(this.mainWindow.tableViews()["Questions"].checkIsValid()).toBe(true);

        var numberOfCells = this.mainWindow.tableViews()["Questions"].cells().length;
        expect(numberOfCells).toEqual(expectNumberOfRows);
    };

    EPHelpers.prototype.getLabel = function() {
        return this.mainWindow.staticTexts()[0].value();
    };

    return EPHelpers;

})();
