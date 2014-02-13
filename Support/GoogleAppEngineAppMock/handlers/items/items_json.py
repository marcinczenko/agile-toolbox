import webapp2
import json
import time
import calendar
from datetime import datetime

from models.questions import QuestionRepository


class ItemsJSON(webapp2.RequestHandler):

    __delay = 1

    @classmethod
    def setDelay(cls,delay):
        cls.__delay = delay

    @staticmethod
    def timestamp_to_float(timestamp):
        return calendar.timegm(timestamp.utctimetuple()) + timestamp.microsecond / 1000000.0

    def convert_to_json(self, items):
        items_json = []
        for item in items:
            items_json.append({'id': item.id,
                               'header': item.header,
                               'content': item.content,
                               'created': self.timestamp_to_float(item.created),
                               'updated': self.timestamp_to_float(item.updated),
                               'answer': item.answer})
        return items_json

    def get_all_questions(self):
        return self.convert_to_json(QuestionRepository.all())

    def get_updated_questions_in_range(self, id_newest, id_oldest):
        items = QuestionRepository.fetch_all_updated_in_range(id_newest, id_oldest)
        return self.convert_to_json(items)

    def get_questions_with_timestamp_before_id(self, question_id, number_of_items_to_fetch):
        if number_of_items_to_fetch:
            items = QuestionRepository.fetch_n_before(int(question_id), int(number_of_items_to_fetch))
        else:
            items = QuestionRepository.fetch_all_before(int(question_id))
        return self.convert_to_json(items)

    def get_questions_with_timestamp_after_id(self, question_id, number_of_items_to_fetch):
        if number_of_items_to_fetch:
            items = QuestionRepository.fetch_n_after(int(question_id), int(number_of_items_to_fetch))
        else:
            items = QuestionRepository.fetch_all_after(int(question_id))
        return self.convert_to_json(items)

    def get(self):

        time.sleep(self.__delay)

        self.response.headers['Content-Type'] = 'application/json'

        if self.request.get('newest'):
            items_new = self.get_questions_with_timestamp_after_id(self.request.get('newest'), self.request.get('n'))
            items_updated = self.get_updated_questions_in_range(self.request.get('newest'), self.request.get('oldest'))
            items_json = {'new': items_new,
                          'updated': items_updated}

        elif self.request.get('before'):
            items_json = {'old': self.get_questions_with_timestamp_before_id(self.request.get('before'),
                                                                             self.request.get('n'))}
        elif self.request.get('n'):
            items_json = {'old': self.get_questions_with_timestamp_before_id(-1, self.request.get('n'))}
        else:
            items_json = {'old': self.get_all_questions()}

        self.response.out.write(json.dumps(items_json))
