import unittest
import webtest
import json

import peewee
from models.questions import QuestionRepository, Question

import main


class ItemsTestCase(unittest.TestCase):
    TEST_ITEM = "Test Item"
    N_FIRST = 20

    def setUp(self):
        Question.truncate()
        self.testapp = webtest.TestApp(main.app)

    def test_checking_that_app_is_ready(self):
        response = self.testapp.get('/ready')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(response.body, "OK")

    def test_retrieving_items_using_json(self):
        QuestionRepository.populate(5)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 5)
        for record_index, record in enumerate(response.json):
            self.assertEqual(record[u'content'], "%s%d" % (ItemsTestCase.TEST_ITEM, 5 - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))

    def test_retrieving_first_n_items_using_json(self):
        QuestionRepository.populate(ItemsTestCase.N_FIRST)
        response = self.testapp.get('/items_json?n=10')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 10)
        for record_index, record in enumerate(response.json):
            self.assertEqual(record[u'content'], "%s%d" % (ItemsTestCase.TEST_ITEM,
                                                           ItemsTestCase.N_FIRST - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))

    def test_retrieving_first_n_items_when_number_of_available_items_less_than_n(self):
        QuestionRepository.populate(5)
        response = self.testapp.get('/items_json?n=10')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 5)

    def test_posting_new_item_using_json(self):
        json_item = [{'content': 'new item'}]
        response = self.testapp.post('/new_json_item', json.dumps(json_item), {'Content-Type': 'application/json'})
        self.assertEqual(response.status_int, 200)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 1)
        item = response.json[0]
        self.assertEqual(item[u'content'], "new item")
