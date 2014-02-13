Feature: Questions Refreshing
  As a user
  I would like to be able to refresh the questions list
  So that I do I can fetch newly added and updated questions from the server

  Scenario: Refreshing: Questions with Fetch More
    Given Google App Engine Server Mock with 50 items and 7 seconds delay is started
    Then RUN: Feature: "QuestionsRefreshing" Scenario:"Refreshing_QuestionsWithFetchMore" (timeout:90)

  Scenario: Refreshing: Questions with No More to Fetch
    Given Google App Engine Server Mock with 39 items and 7 seconds delay is started
    Then RUN: Feature: "QuestionsRefreshing" Scenario:"Refreshing_QuestionsWithNoMoreToFetch" (timeout:90)

  Scenario: Refreshing: Questions with No More to Fetch with just few items
    Given Google App Engine Server Mock with 3 items and 7 seconds delay is started
    Then RUN: Feature: "QuestionsRefreshing" Scenario:"Refreshing_QuestionsWithNoMoreToFetchFewItems" (timeout:60)