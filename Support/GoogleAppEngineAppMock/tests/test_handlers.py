import unittest
import webapp2
import webtest
import json

from models.items import ItemsModel

import main

class ItemsTestCase(unittest.TestCase):
    
    TEST_ITEM = "Test Item"
    
    def setUp(self):
        self.testapp = webtest.TestApp(main.app)
    
    def test_checking_that_app_is_ready(self):
        response = self.testapp.get('/ready')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(response.body,"OK")
            
    def test_retrieving_items_using_json(self):
        ItemsModel.populate(5)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json),5)
        for record_index,record in enumerate(response.json):
            self.assertEqual(record[u'content'],"%s%d" % (ItemsTestCase.TEST_ITEM,record_index),"record_index:%d, record:%s" % (record_index,record))
    
    def test_posting_new_item_using_json(self):
        json_item = [{'content':'new item'}]
        response = self.testapp.post('/new_json_item',json.dumps(json_item),{'Content-Type':'application/json'})
        self.assertEqual(response.status_int, 200)
        response = self.testapp.get('/items_json')
        self.assertEqual(response.status_int, 200)
        self.assertEqual(len(response.json),1)
        item = response.json[0]
        self.assertEqual(item[u'content'],"new item")



        
