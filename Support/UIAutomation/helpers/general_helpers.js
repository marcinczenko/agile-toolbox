
var EPHelpers = (function() {

    function EPHelpers() {
//        this.target = UIATarget.localTarget();
//        this.mainWindow = this.target.frontMostApp().mainWindow();
    }

    EPHelpers.prototype.target = function() {
        return UIATarget.localTarget();
    }

    EPHelpers.prototype.mainWindow = function() {
        return this.target().frontMostApp().mainWindow();
    }

    EPHelpers.prototype.goBack = function(delay) {
        var delay = delay || 0;
        this.target().frontMostApp().navigationBar().leftButton().tap();
        this.target().delay(delay);
    };

    EPHelpers.prototype.enterQuestions = function(delay) {
        delay = delay || 2;
        this.mainWindow().tableViews()["MenuList"].cells()["Q&A"].tap();
        this.target().delay(delay);
    };

    // fetchMore works as follows: it first scroll far enough (but not to far) so that the following call to
    // scrollDown() pushes the tableview beyond the last row triggering the 'fetch more' operation.
    // I could not achieve the same effect any other way. The numbers chosen are purely experimental.
    EPHelpers.prototype.fetchMoreInTableView = function(tableView) {

        this.scrollToCellInTableViewAtIndex(tableView,this.getNumberOfCellsInTableView(tableView)-7);

//        this.mainWindow().tableViews()["Questions"].cells()[numberOfCellsInTableView-14].scrollToVisible();
//
//        var cell = this.mainWindow().tableViews()["Questions"].cells()[numberOfCellsInTableView-14];
//
        this.target().delay(1);

        this.mainWindow().tableViews()[tableView].scrollDown();

        this.target().delay(1.5);
    };

    EPHelpers.prototype.refreshTableView = function(tableView,extraDelay) {
        this.scrollToFirstCellInTableView(tableView);

        this.mainWindow().tableViews()["Questions"].scrollUp();
//        this.mainWindow().tableViews()["Questions"].scrollUp();

        var delay = extraDelay || 1.5;
        this.target().delay(delay);
    };

    EPHelpers.prototype.checkThereIsACorrectNumberOfRowsInTheTableView = function(expectNumberOfRows){
        expect(this.mainWindow().tableViews()["Questions"].checkIsValid()).toBe(true);

        var numberOfCells = this.mainWindow().tableViews()["Questions"].cells().length;
        expect(numberOfCells).toEqual(expectNumberOfRows);
    };

    EPHelpers.prototype.getNumberOfCellsInTableView = function(tableView){
        return this.mainWindow().tableViews()[tableView].cells().length;
    };

    EPHelpers.prototype.getCellTextForTableViewAtIndex = function(tableView,cellIndex){
        return this.mainWindow().tableViews()[tableView].cells()[cellIndex].name();
    };

    EPHelpers.prototype.getCellTextForFirstElementInTableView = function(tableView){
        return this.mainWindow().tableViews()[tableView].cells()[0].name();
    };

    EPHelpers.prototype.getCellTextForLastElementInTableView = function(tableView){
        number_of_cells = this.getNumberOfCellsInTableView(tableView);
        return this.mainWindow().tableViews()[tableView].cells()[number_of_cells-1].name();
    };

    EPHelpers.prototype.getVisibleCellTextForTableViewAtIndex = function(tableView,cellIndex){
        return this.mainWindow().tableViews()[tableView].visibleCells()[cellIndex].name();
    };

    EPHelpers.prototype.getLastVisibleCellTextForTableView = function(tableView){
        var visibleCells = this.mainWindow().tableViews()[tableView].visibleCells();
        return visibleCells[visibleCells.length-1].name();
    };

    EPHelpers.prototype.getLastVisibleCellElementForTableView = function(tableView){
        var visibleCells = this.mainWindow().tableViews()[tableView].visibleCells();
        return visibleCells[visibleCells.length-1];
    };

    EPHelpers.prototype.getFirstVisibleCellTextForTableView = function(tableView){
        var visibleCells = this.mainWindow().tableViews()[tableView].visibleCells();
        return visibleCells[0].name();
    };

    // This one is dangerous - avoid using scrollToElementWithName - after using it once
    // resolving cells by name does not work any more and scrolling is broken.
    // Use saver version of this method that scrolls to the first, last, or to an item
    // at specific index.
    EPHelpers.prototype.scrollToCellWithName = function(tableView,cellName){
        this.mainWindow().tableViews()[tableView].scrollToElementWithName(cellName);
    };

    EPHelpers.prototype.scrollToCellInTableViewAtIndex = function(tableView,index){
        var cells = this.mainWindow().tableViews()[tableView].cells();
        cells[index].scrollToVisible();
    };

    EPHelpers.prototype.scrollToFirstCellInTableView = function(tableView){
        var cells = this.mainWindow().tableViews()[tableView].cells();
        cells[0].scrollToVisible();
    };

    EPHelpers.prototype.scrollToLastCellInTableView = function(tableView){
        var cells = this.mainWindow().tableViews()[tableView].cells();
        cells[cells.length-1].scrollToVisible();
    };

    EPHelpers.prototype.getLabel = function() {
        return this.mainWindow().staticTexts()[0].value();
    };

    EPHelpers.prototype.enterBackgroundForDuration = function(duration) {
        this.target().deactivateAppForDuration(duration);
    };

    return EPHelpers;

})();
