import peewee
import datetime
import calendar

import sqlite_model


class Question(sqlite_model.SQLiteModel):
    header = peewee.TextField()
    content = peewee.TextField()
    created = peewee.DateTimeField()
    updated = peewee.DateTimeField()
    answer = peewee.TextField(null=True)
    accepted = peewee.BooleanField(default=True)

    class Meta:
        # db_table = 'questions'
        order_by = ('-created',)


class QuestionRepository(object):
    PAGE_SIZE = 40

    @classmethod
    def all(cls):
        return Question.select()

    @classmethod
    def fetch_all_updated_in_range_updated_after(cls, question_id_newest, question_id_oldest, updated_after_timestamp):
        reference_question_newest = Question.select().where(Question.id == question_id_newest).get()
        reference_question_oldest = Question.select().where(Question.id == question_id_oldest).get()
        return Question.select().where(
            (Question.created <= reference_question_newest.created) &
            (Question.created >= reference_question_oldest.created) &
            (Question.updated > datetime.datetime.utcfromtimestamp(updated_after_timestamp)))

    @classmethod
    def fetch_n_updated_after(cls, timestamp, n):
        query = cls.all().order_by(Question.updated)

        return query.where(Question.updated > datetime.datetime.utcfromtimestamp(timestamp)).paginate(1, n)

    @classmethod
    def fetch_all_before(cls, question_id):
        reference_question = Question.select().where(Question.id == question_id).get()
        return Question.select().where(Question.created < reference_question.created)

    @classmethod
    def fetch_n_before(cls, question_id, n):
        if -1 == question_id:
            return Question.select().paginate(1, n)
        else:
            reference_question = Question.select().where(Question.id == question_id).get()
            return Question.select().where(Question.created < reference_question.created).paginate(1, n)

    @classmethod
    def add_item_with_header_and_content(cls, header, content):
        timestamp = datetime.datetime.utcnow()
        Question.create(header=header, content=content, created=timestamp, updated=timestamp, answer='')

    @classmethod
    def populate(cls, number_of_items):
        start_index = cls.all().count()

        for item_index in range(0+start_index, number_of_items+start_index):
            timestamp = datetime.datetime.utcnow()
            Question.create(header="Header for question %d" % item_index, content="Content for question %d" % item_index,
                            created=timestamp, updated=timestamp)

    @classmethod
    def update_items(cls, list_of_items_id_to_update):
        update_query = Question.update(updated=datetime.datetime.utcnow(), content='*** UPDATED ***').where(
            Question.id << list_of_items_id_to_update)
        update_query.execute()

    @classmethod
    def add_answers(cls, list_of_items_id_to_update):
        update_query = Question.update(updated=datetime.datetime.utcnow(), answer='Answer').where(
            Question.id << list_of_items_id_to_update)
        update_query.execute()

    @classmethod
    def update_item(cls, item_id, header, content, answer):
        update_query = Question.update(updated=datetime.datetime.utcnow(), header=header, content=content,
                                       answer=answer).where(Question.id == item_id)
        update_query.execute()

    @classmethod
    def create_table(cls):
        Question.create_table_if_does_not_exist()

    @classmethod
    def truncate(cls):
        Question.truncate()
