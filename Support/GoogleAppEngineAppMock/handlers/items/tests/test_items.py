import unittest
import webtest
import json
import calendar
from datetime import datetime

from models.questions import QuestionRepository

import main


class ItemsTestCase(unittest.TestCase):
    TEST_ITEM = "Test Item"
    HEADER_FOR_ITEM = "Header for Item"

    NUMBER_OF_QUESTIONS = 100
    PAGE_SIZE = 40

    def setUp(self):
        QuestionRepository.create_table()
        QuestionRepository.truncate()
        self.testapp = webtest.TestApp(main.app)

    def test_checking_that_app_is_ready(self):
        response = self.testapp.get('/ready')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(response.body, "OK")

    def test_each_question_has_unique_id(self):
        QuestionRepository.populate(2)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 2)
        self.assertNotEqual(items[0][u'id'], items[1][u'id'])

    def test_each_question_has_timestamp_encoded_as_float(self):
        QuestionRepository.populate(2)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 2)
        self.assertGreater(items[0][u'timestamp'],
                           items[1][u'timestamp'])

    def test_each_question_has_updated_field_that_is_equal_to_timestamp_field(self):
        QuestionRepository.populate(1)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0][u'timestamp'],
                         items[0][u'updated'])

    def test_retrieving_items_using_json(self):
        QuestionRepository.populate(5)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 5)
        for record_index, record in enumerate(items):
            self.assertEqual(record[u'content'], "%s%d" % (ItemsTestCase.TEST_ITEM, 5 - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))
            self.assertEqual(record[u'header'], "%s%d" % (ItemsTestCase.HEADER_FOR_ITEM, 5 - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))

    def test_retrieving_first_n_items_posted_after_items_with_given_id(self):
        QuestionRepository.populate(15)
        response = self.testapp.get('/items_json?n=5')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 5)
        oldest_item_id = items[4][u'id']
        self.assertEqual(11, oldest_item_id)
        response = self.testapp.get("/items_json?id=%d&n=5" % oldest_item_id)
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 5)
        self.assertEqual(10, items[0][u'id'])
        self.assertEqual(6, items[4][u'id'])

    def test_retrieving_first_n_items(self):
        QuestionRepository.populate(20)
        response = self.testapp.get('/items_json?n=10')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 10)

    def test_retrieving_first_n_items_when_number_of_available_items_less_than_n(self):
        QuestionRepository.populate(5)
        response = self.testapp.get('/items_json?n=10')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 5)

    def test_posting_new_item_using_json(self):
        json_item = [{'header': 'new item header', 'content': 'new item'}]
        response = self.testapp.post('/new_json_item', json.dumps(json_item), {'Content-Type': 'application/json'})
        self.assertEqual(response.status_int, 200)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        self.assertEqual(len(items), 1)
        item = items[0]
        self.assertEqual(item[u'content'], "new item")
