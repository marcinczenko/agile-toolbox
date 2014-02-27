import webapp2

from paste import httpserver
import argparse

from handlers.items.items_json import ItemsJSON
from handlers.items.new_item import NewItem
from handlers.items.add_more import AddMore
from handlers.items.update import Update
from handlers.items.answer import Answer
from handlers.helpers import Ready
from models.questions import QuestionRepository

app = webapp2.WSGIApplication([(ItemsJSON.URL, ItemsJSON),
                               (Ready.URL, Ready),
                               (NewItem.URL, NewItem),
                               (AddMore.URL, AddMore),
                               (Update.URL, Update),
                               (Answer.URL, Answer)],
                              debug=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', action="store", default=0, dest="number_of_items", type=int,
                        help="Number of test items in data store after initialization.")

    parser.add_argument('-d', action="store", default=0, dest="delay", type=int,
                        help="Delay in finishing request in seconds. Used to simulate slow server connection.")

    QuestionRepository.create_table()
    QuestionRepository.truncate()
    QuestionRepository.populate(parser.parse_args().number_of_items)
    ItemsJSON.set_delay(parser.parse_args().delay)

    httpserver.serve(app, host='0.0.0.0', port='9001')


if __name__ == '__main__':
    main()
