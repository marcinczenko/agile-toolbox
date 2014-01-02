import webapp2

from paste import httpserver
import argparse

from handlers.items.items_json import ItemsJSON
from handlers.items.new_item import NewItem
from handlers.helpers import Ready
from models.questions import QuestionRepository

app = webapp2.WSGIApplication([('/items_json', ItemsJSON),
                               ('/ready', Ready),
                               ('/new_json_item', NewItem)],
                              debug=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', action="store", default=0, dest="number_of_items", type=int,
                        help="Number of test items in data store after initialization.")

    QuestionRepository.create_table()
    QuestionRepository.truncate()
    QuestionRepository.populate(parser.parse_args().number_of_items)

    httpserver.serve(app, host='192.168.1.33', port='9001')


if __name__ == '__main__':
    main()

