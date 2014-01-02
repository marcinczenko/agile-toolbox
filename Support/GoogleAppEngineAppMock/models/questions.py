import peewee
import datetime

import sqlite_model


class Question(sqlite_model.SQLiteModel):
    content = peewee.TextField()
    timestamp = peewee.DateTimeField()

    class Meta:
        # db_table = 'questions'
        order_by = ('-timestamp',)


class QuestionRepository(object):

    PAGE_SIZE = 40

    @classmethod
    def all(cls):
        return Question.select()

    @classmethod
    def fetch_page(cls, page):
        # return [q.contents for q in Question.select().paginate(page, cls.PAGE_SIZE)]
        return Question.select().paginate(page, cls.PAGE_SIZE)

    @classmethod
    def add_item(cls, item):
        Question.create(content=item, timestamp=datetime.datetime.now())

    @classmethod
    def populate(cls, number_of_items):
        for item_index in range(0, number_of_items):
            Question.create(content="Test Item%d" % item_index, timestamp=datetime.datetime.now())

    @classmethod
    def create_table(cls):
        Question.create_table_if_does_not_exist()

    @classmethod
    def truncate(cls):
        Question.truncate()
