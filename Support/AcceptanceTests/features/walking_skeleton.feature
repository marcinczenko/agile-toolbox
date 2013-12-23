Feature: Walking skeleton
  In order to start development at a sustainable pace
  As a developer
  I would like to deliver a simple functionality that triggers initial architectural discussion and drives creating the testing infrastructure

Scenario: Retrieving text items form the server
  Given Google App Engine Server Mock with 5 items is started
  Then I should be able to retrieve these 5 items using my iPhone App (Feature: "WalkingSkeleton" Scenario:"RetrievingItemsFromTheServer")
  
Scenario: Posting a new text item to the server
  Given Google App Engine Server Mock with 5 items is started
  Then I should be able to add a new item using my iPhone App (Feature: "WalkingSkeleton" Scenario:"PostingNewItemToTheServer")