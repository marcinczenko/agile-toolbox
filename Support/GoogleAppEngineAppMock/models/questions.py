import peewee
import datetime

import sqlite_model


class Question(sqlite_model.SQLiteModel):
    header = peewee.TextField()
    content = peewee.TextField()
    timestamp = peewee.DateTimeField()
    updated = peewee.DateTimeField()

    class Meta:
        # db_table = 'questions'
        order_by = ('-timestamp',)


class QuestionRepository(object):
    PAGE_SIZE = 40

    @classmethod
    def all(cls):
        return Question.select()

    @classmethod
    def fetch_all_updated_in_range(cls, question_id_begin, question_id_end):
        reference_question_begin = Question.select().where(Question.id == question_id_begin).get()
        reference_question_end = Question.select().where(Question.id == question_id_end).get()
        return Question.select().where(
            (Question.updated > reference_question_begin.timestamp) &
            (Question.timestamp <= reference_question_begin) &
            (Question.timestamp >= reference_question_end))

    @classmethod
    def fetch_all_after(cls, question_id):
        reference_question = Question.select().where(Question.id == question_id).get()
        return Question.select().where(Question.timestamp > reference_question.timestamp)

    @classmethod
    def fetch_n_after(cls, id, n):
        reference_question = Question.select().where(Question.id == id).get()
        return Question.select().where(Question.timestamp > reference_question.timestamp).paginate(1, n)

    @classmethod
    def fetch_all_before(cls, question_id):
        reference_question = Question.select().where(Question.id == question_id).get()
        return Question.select().where(Question.timestamp < reference_question.timestamp)

    @classmethod
    def fetch_n_before(cls, id, n):
        # return [q.contents for q in Question.select().paginate(page, cls.PAGE_SIZE)]
        if -1 == id:
            return Question.select().paginate(1, n)
        else:
            reference_question = Question.select().where(Question.id == id).get()
            return Question.select().where(Question.timestamp < reference_question.timestamp).paginate(1, n)

    @classmethod
    def add_item_with_header_and_content(cls, header, content):
        timestamp = datetime.datetime.utcnow()
        Question.create(header=header, content=content, timestamp=timestamp, updated=timestamp)

    @classmethod
    def populate(cls, number_of_items):
        for item_index in range(0, number_of_items):
            timestamp = datetime.datetime.utcnow()
            Question.create(header="Header for Item%d" % item_index, content="Test Item%d" % item_index,
                            timestamp=timestamp, updated=timestamp)

    @classmethod
    def create_table(cls):
        Question.create_table_if_does_not_exist()

    @classmethod
    def truncate(cls):
        Question.truncate()
