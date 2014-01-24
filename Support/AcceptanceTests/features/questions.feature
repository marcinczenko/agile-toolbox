Feature: Questions
  As a user
  I would like to see the list of questions already posted
  So that I can find out if my question was already asked

Scenario: Retrieving text items form the server
  Given Google App Engine Server Mock with 5 items is started
  Then I should be able to retrieve these 5 items using my iPhone App (Feature: "Questions" Scenario:"RetrievingItemsFromTheServer")

Scenario: Retrieving first n items form the server
  Given Google App Engine Server Mock with 60 items is started
  Then RUN: Feature: "Questions" Scenario:"RetrievingFirstPageFromTheServer"

Scenario: Pagination
  Given Google App Engine Server Mock with 81 items is started
  Then RUN: Feature: "Questions" Scenario:"Pagination"

Scenario: Re-entering the questions list does not trigger fetch
  Given Google App Engine Server Mock with 41 items is started
  Then RUN: Feature: "Questions" Scenario:"ReenteringTheQuestionsListACoupleOfTimes"

@ignore
Scenario: Posting a new text item to the server
  Given Google App Engine Server Mock with 5 items is started
  Then I should be able to add a new item using my iPhone App (Feature: "Questions" Scenario:"PostingNewItemToTheServer")

Scenario: Re-entering the questions list does not trigger fetch
  Given Google App Engine Server Mock with 40 items is started
  Then RUN: Feature: "Questions" Scenario:"ServerReturnsZeroQuestionsAfterFetchingFullPage"
