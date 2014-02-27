import webapp2
import json

from models.questions import QuestionRepository


class NewItem(webapp2.RequestHandler):
    URL = '/add_question_json'

    def post(self):
        new_json_item = json.loads(self.request.body)
        QuestionRepository.add_item_with_header_and_content(new_json_item[0]['header'],
                                                            new_json_item[0]['content'])
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('ADDED')
