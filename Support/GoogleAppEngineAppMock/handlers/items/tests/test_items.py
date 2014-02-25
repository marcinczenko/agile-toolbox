import unittest
import webtest
import json

from models.questions import QuestionRepository

import main


class ItemsTestCase(unittest.TestCase):
    TEST_ITEM = "Test Item"
    HEADER_FOR_ITEM = "Header for Item"

    NUMBER_OF_QUESTIONS = 100
    PAGE_SIZE = 40

    def retrieve_first_n_items(self, number_of_items):
        response = self.testapp.get('/items_json?n=%d' % number_of_items)
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        return items

    def retrieve_first_n_items_before_item_with_id(self, item_id, number_of_items):
        response = self.testapp.get("/items_json?before=%d&n=%d" % (item_id, number_of_items))
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        return items

    def retrieve_first_n_items_posted_after_item_with_id(self, newest_item_id, oldest_item_id, number_of_items):
        response = self.testapp.get("/items_json?newest=%d&oldest=%d&n=%d" % (newest_item_id, oldest_item_id,
                                                                              number_of_items))
        self.assertEqual(response.status_int, 200)
        items = response.json['new']
        self.assertIsNotNone(items)
        return items

    def retrieve_first_n_and_updated_items_posted_after_item_with_id(self, newest_item_id, oldest_item_id,
                                                                     number_of_items):
        response = self.testapp.get("/items_json?newest=%d&oldest=%d&n=%d" % (newest_item_id, oldest_item_id,
                                                                              number_of_items))
        self.assertEqual(response.status_int, 200)
        new_items = response.json['new']
        self.assertIsNotNone(new_items)
        updated_items = response.json['updated']
        self.assertIsNotNone(updated_items)
        return new_items, updated_items

    def retrieve_all_items(self):
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        items = response.json['old']
        self.assertIsNotNone(items)
        return items

    def add_more_items(self, number_of_items=None):
        if not number_of_items:
            response = self.testapp.get('/add_more')
        else:
            response = self.testapp.get('/add_more?n=%d' % number_of_items)
        self.assertEqual(response.status_int, 200)
        self.assertEqual(response.body, "OK")

    def update_items(self, items_ids):
        request_url = '/update_ids?'
        param_separator = ''
        for item_id in items_ids:
            request_url += '%sid=%d' % (param_separator, item_id)
            param_separator = '&'
        response = self.testapp.get(request_url)
        self.assertEqual(response.status_int, 200)
        self.assertEqual(response.body, "OK")


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

        items = self.retrieve_all_items()

        self.assertEqual(len(items), 2)
        self.assertNotEqual(items[0][u'id'], items[1][u'id'])

    def test_each_question_has_timestamp_encoded_as_float(self):
        QuestionRepository.populate(2)

        items = self.retrieve_all_items()
        self.assertEqual(len(items), 2)

        self.assertEqual(len(items), 2)
        self.assertGreater(items[0][u'created'],
                           items[1][u'created'])

    def test_each_question_has_updated_field_that_is_equal_to_timestamp_field(self):
        QuestionRepository.populate(1)

        items = self.retrieve_all_items()
        self.assertEqual(len(items), 1)

        self.assertEqual(len(items), 1)
        self.assertEqual(items[0][u'created'],
                         items[0][u'updated'])

    def test_retrieving_items_using_json(self):
        QuestionRepository.populate(5)

        items = self.retrieve_all_items()
        self.assertEqual(len(items), 5)

        self.assertEqual(len(items), 5)
        for record_index, record in enumerate(items):
            self.assertEqual(record[u'content'], "%s%d" % (ItemsTestCase.TEST_ITEM, 5 - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))
            self.assertEqual(record[u'header'], "%s%d" % (ItemsTestCase.HEADER_FOR_ITEM, 5 - record_index - 1),
                             "record_index:%d, record:%s" % (record_index, record))

    def test_retrieving_first_n_items_posted_before_item_with_given_id(self):
        QuestionRepository.populate(15)

        items = self.retrieve_first_n_items(5)
        self.assertEqual(len(items), 5)

        oldest_item_id = items[4][u'id']
        self.assertEqual(11, oldest_item_id)

        items = self.retrieve_first_n_items_before_item_with_id(oldest_item_id, 5)
        self.assertEqual(len(items), 5)
        self.assertEqual(10, items[0][u'id'])
        self.assertEqual(6, items[4][u'id'])

    def test_retrieving_first_n_items(self):
        QuestionRepository.populate(20)
        items = self.retrieve_first_n_items(10)
        self.assertEqual(len(items), 10)

    def test_retrieving_first_n_items_when_number_of_available_items_less_than_n(self):
        QuestionRepository.populate(5)

        items = self.retrieve_first_n_items(10)
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
        self.assertEqual(item[u'header'], "new item header"
                                          "")

    def test_retrieving_first_n_items_posted_after_item_with_given_id(self):
        QuestionRepository.populate(10)

        items = self.retrieve_first_n_items(5)

        most_recent_item_id = items[0][u'id']
        self.assertEqual(10, most_recent_item_id)
        oldest_item_id = items[4][u'id']
        self.assertEqual(6, oldest_item_id)

        number_of_new_items = 5
        QuestionRepository.populate(number_of_new_items)

        new_items = self.retrieve_first_n_items_posted_after_item_with_id(most_recent_item_id, oldest_item_id,
                                                                          number_of_new_items)
        self.assertEqual(len(new_items), number_of_new_items)
        self.assertEqual(15, new_items[0][u'id'])
        self.assertEqual(11, new_items[4][u'id'])

    def test_retrieving_updated_items(self):
        QuestionRepository.populate(10)

        items = self.retrieve_first_n_items(5)

        most_recent_item_id = items[0][u'id']
        self.assertEqual(10, most_recent_item_id)
        oldest_item_id = items[4][u'id']
        self.assertEqual(6, oldest_item_id)

        number_of_new_items = 5
        QuestionRepository.populate(number_of_new_items)
        list_of_items_to_be_updated = [6, 8, 10]
        QuestionRepository.update_items(list_of_items_to_be_updated)

        new_items, updated_items = self.retrieve_first_n_and_updated_items_posted_after_item_with_id(
            most_recent_item_id, oldest_item_id, number_of_new_items)

        self.assertEqual(len(new_items), number_of_new_items)

        self.assertEqual(15, new_items[0][u'id'])
        self.assertEqual(11, new_items[4][u'id'])

        self.assertEqual(len(updated_items), len(list_of_items_to_be_updated))
        self.assertIn(updated_items[0][u'id'], list_of_items_to_be_updated)
        self.assertIn(updated_items[1][u'id'], list_of_items_to_be_updated)
        self.assertIn(updated_items[2][u'id'], list_of_items_to_be_updated)

    def test_retrieving_updated_items_does_not_include_items_outside_of_the_requested_range(self):
        QuestionRepository.populate(10)

        items = self.retrieve_first_n_items(5)

        most_recent_item_id = items[0][u'id']
        self.assertEqual(10, most_recent_item_id)
        oldest_item_id = items[4][u'id']
        self.assertEqual(6, oldest_item_id)

        number_of_new_items = 5
        QuestionRepository.populate(number_of_new_items)
        QuestionRepository.update_items([1, 3, 5])

        new_items, updated_items = self.retrieve_first_n_and_updated_items_posted_after_item_with_id(
            most_recent_item_id, oldest_item_id, number_of_new_items)

        self.assertEqual(len(new_items), number_of_new_items)

        self.assertEqual(15, new_items[0][u'id'])
        self.assertEqual(11, new_items[4][u'id'])

        self.assertEqual(len(updated_items), 0)

    def test_retrieving_updated_items_when_no_new_items_have_been_added(self):
        QuestionRepository.populate(10)

        items = self.retrieve_first_n_items(5)

        most_recent_item_id = items[0][u'id']
        self.assertEqual(10, most_recent_item_id)
        oldest_item_id = items[4][u'id']
        self.assertEqual(6, oldest_item_id)

        list_of_items_to_be_updated = [6, 8, 10]
        QuestionRepository.update_items(list_of_items_to_be_updated)

        new_items, updated_items = self.retrieve_first_n_and_updated_items_posted_after_item_with_id(
            most_recent_item_id, oldest_item_id, 5)

        self.assertEqual(len(new_items), 0)

        self.assertEqual(len(updated_items), len(list_of_items_to_be_updated))

        self.assertIn(updated_items[0][u'id'], list_of_items_to_be_updated)
        self.assertIn(updated_items[1][u'id'], list_of_items_to_be_updated)
        self.assertIn(updated_items[2][u'id'], list_of_items_to_be_updated)

    def test_adding_an_answer_to_a_question(self):
        QuestionRepository.populate(2)

        items = self.retrieve_all_items()

        self.assertEqual(len(items), 2)
        item = items[0]
        self.assertIsNone(item[u'answer'])

        QuestionRepository.update_item(item[u'id'], item[u'header'], item[u'content'], "New Answer")
        items = self.retrieve_all_items()
        item = items[0]
        self.assertIsNotNone(item[u'answer'])
        self.assertEqual("New Answer", item[u'answer'])
        self.assertGreater(item[u'updated'], item[u'created'])

    def test_adding_more_items_to_the_database_using_add_more_get_request_with_default_number_of_items(self):
        QuestionRepository.populate(10)

        items = self.retrieve_all_items()

        self.assertEqual(len(items), 10)
        item = items[0]
        self.assertEqual(10, item[u'id'])

        self.add_more_items()

        items = self.retrieve_all_items()
        self.assertEqual(len(items), 20)
        item = items[0]
        self.assertEqual(20, item[u'id'])

    def test_adding_more_items_to_the_database_using_add_more_get_request_with_explicit_number_of_items(self):
        QuestionRepository.populate(10)

        items = self.retrieve_all_items()

        self.assertEqual(len(items), 10)
        item = items[0]
        self.assertEqual(10, item[u'id'])

        self.add_more_items(50)

        items = self.retrieve_all_items()
        self.assertEqual(len(items), 60)
        item = items[0]
        self.assertEqual(60, item[u'id'])

    def test_updating_selected_items_using_get_request(self):
        QuestionRepository.populate(5)
        self.update_items([5, 3, 1])

        new_items, updated_items = self.retrieve_first_n_and_updated_items_posted_after_item_with_id(5, 1, 5)
        self.assertEqual(0, len(new_items))
        self.assertEqual(3, len(updated_items))





