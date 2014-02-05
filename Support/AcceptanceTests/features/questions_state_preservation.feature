Feature: Questions State Preservation
  As a user
  I would like to see the same questions when leave and then enter back the questions screen
  So that I do not have to search for the question I was looking at before leaving the questions screen

Scenario: Preservation: empty loading
  Given Google App Engine Server Mock with 50 items is started
  Then RUN: Feature: "QuestionsStatePreservation" Scenario:"Preservation_EmptyLoading"

Scenario: Preservation: questions loading
  Given Google App Engine Server Mock with 50 items is started
  Then RUN: Feature: "QuestionsStatePreservation" Scenario:"Preservation_QuestionsLoading"

Scenario: Preservation: loading with background fetch
  Given Google App Engine Server Mock with 50 items and 5 seconds delay is started
  Then RUN: Feature: "QuestionsStatePreservation" Scenario:"Preservation_LoadingWithBackgroundFetch" (timeout:35)
