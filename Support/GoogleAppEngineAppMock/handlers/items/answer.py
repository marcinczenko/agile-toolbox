
import webapp2

from models.questions import QuestionRepository


class Answer(webapp2.RequestHandler):
    URL = '/answer_ids'

    def get(self):
        ids_of_items_to_update = [int(items_id) for items_id in self.request.get_all('id')]

        if ids_of_items_to_update:
            QuestionRepository.add_answers(ids_of_items_to_update)

        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('OK')
