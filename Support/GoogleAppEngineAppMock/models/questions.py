import peewee
import datetime

import sqlite_model


class Question(sqlite_model.SQLiteModel):
    contents = peewee.TextField()
    timestamp = peewee.DateTimeField()

    class Meta:
        # db_table = 'questions'
        order_by = ('-timestamp',)


class QuestionRepository(object):

    Question.create_table_if_does_not_exist()
    Question.truncate()

    @classmethod
    def all(cls):
        return [q.contents for q in Question.select()]

    @classmethod
    def fetch(cls, n):
        return [q.contents for q in Question.select().paginate(1, n)]

    @classmethod
    def add_item(cls, item):
        Question.create(contents=item, timestamp=datetime.datetime.now())

    @classmethod
    def populate(cls, number_of_items):
        for item_index in range(0, number_of_items):
            Question.create(contents="Test Item%d" % item_index, timestamp=datetime.datetime.now())
