import unittest
import webtest
import json
import calendar
from datetime import datetime

from models.questions import QuestionRepository

import main


class ItemsTestCase(unittest.TestCase):
    TEST_ITEM = "Test Item"

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
        self.assertEqual(len(response.json), 2)
        self.assertNotEqual(response.json[0][u'id'], response.json[1][u'id'])

    def test_each_question_has_timestamp_encoded_as_float(self):
        QuestionRepository.populate(2)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 2)
        self.assertGreater(response.json[0][u'timestamp'],
                           response.json[1][u'timestamp'])

    def test_retrieving_items_using_json(self):
        QuestionRepository.populate(5)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 5)
        for record_index, record in enumerate(response.json):
            self.assertEqual(record[u'content'], "%s%d" % (ItemsTestCase.TEST_ITEM, 5 - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))

    def test_retrieving_first_n_items_posted_after_items_with_given_id(self):
        QuestionRepository.populate(15)
        response = self.testapp.get('/items_json?n=5')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 5)
        oldest_item_id = response.json[4][u'id']
        self.assertEqual(11, oldest_item_id)
        response = self.testapp.get("/items_json?id=%d&n=5" % oldest_item_id)
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 5)
        self.assertEqual(10, response.json[0][u'id'])
        self.assertEqual(6, response.json[4][u'id'])

    def test_retrieving_first_n_items(self):
        QuestionRepository.populate(20)
        response = self.testapp.get('/items_json?n=10')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json), 10)

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
