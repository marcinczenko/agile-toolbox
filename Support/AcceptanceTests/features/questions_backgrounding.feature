Feature: Questions Backgrounding
  As a user
  I would like to have questions fetched in the background
  So that I can take advantage of multitasking on my iOS device

Scenario: Backgrounding: empty no questions
  Given Google App Engine Server Mock with 0 items and 4 seconds delay is started
  Then RUN: Feature: "QuestionsBackgrounding" Scenario:"Backgrounding_EmptyNoQuestions"

Scenario: Backgrounding: fetching just a view questions (less than a screen)
  Given Google App Engine Server Mock with 3 items and 5 seconds delay is started
  Then RUN: Feature: "QuestionsBackgrounding" Scenario:"Backgrounding_FewQuestions"

Scenario: Backgrounding: fetching exactly one page of questions
  Given Google App Engine Server Mock with 40 items and 5 seconds delay is started
  Then RUN: Feature: "QuestionsBackgrounding" Scenario:"Backgrounding_OnePage"

Scenario: Backgrounding: more than one page of questions on the server
  Given Google App Engine Server Mock with 45 items and 5 seconds delay is started
  Then RUN: Feature: "QuestionsBackgrounding" Scenario:"Backgrounding_MoreThanOnePage"

Scenario: Backgrounding: more than one page and background when table view invisible
  Given Google App Engine Server Mock with 45 items and 5 seconds delay is started
  Then RUN: Feature: "QuestionsBackgrounding" Scenario:"Backgrounding_MoreThanOnePageViewNotVisible" (timeout:45)