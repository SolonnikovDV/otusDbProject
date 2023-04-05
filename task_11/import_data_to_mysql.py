from sqlalchemy import create_engine
from csv_to_nf3 import csv_to_df, split_df, insert_col_to_df, hash_id_generate
import utils.config as cfg
from utils.get_time import current_time
import pandas as pd

DB_NAME = 'ecom_events'
USER =  cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT


'''
'df_event', 'df_cat', 'df_prod', 'df_session'
'''

def insert_data_to_mysql(df_dict: dict, df_name: str):
    print(f'INFO: {current_time()} >> Import dataframe {df_name} to mysql db {DB_NAME}')

    # getting df from dictionary
    df = df_dict[f'{df_name}']

    list_ = [
        [1, 6, 'asdas', 'qweqw'],
        [2, 7, 'asdasd', 'asdasd'],
        [3, 8, 'wdasdfa', 'asfas'],
        [4, 9, 'asda', 'dfhdf']
    ]
    cols = ['key1', 'key2', 'val1', 'val2']
    custom_df = pd.DataFrame(list_, columns=cols)

    # create connection to mysql db
    sql_engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}', pool_recycle=3600)
    db_connection = sql_engine.connect()

    try:
        # df.to_sql(df_name, db_connection, if_exists='replace', index=False)
        custom_df.to_sql('test', db_connection, if_exists='replace', index=False)
    except ValueError as vx:
        print(vx)
    except Exception as ex:
        print(ex)
    else:
        print(f'INFO: {current_time()} >> Table {df_name} created successfully.')
    finally:
        db_connection.close()


def insert_data():

    list_ = [
        [1, 6, 'asdas', 'qweqw'],
        [2, 7, 'asdasd', 'asdasd'],
        [3, 8, 'wdasdfa', 'asfas'],
        [4, 9, 'asda', 'dfhdf']
    ]
    cols = ['key1', 'key2', 'val1', 'val2']
    custom_df = pd.DataFrame(list_, columns=cols)

    # create connection to mysql db
    sql_engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}', pool_recycle=3600)
    db_connection = sql_engine.connect()

    try:
        # df.to_sql(df_name, db_connection, if_exists='replace', index=False)
        custom_df.to_sql('test123', db_connection, if_exists='replace', index=False)
    except ValueError as vx:
        print(vx)
    except Exception as ex:
        print(ex)
    else:
        print(f'INFO: {current_time()} >> Table created successfully.')
    finally:
        db_connection.close()

if __name__ == '__main__':
    # dict_of_df = split_df(insert_col_to_df(csv_to_df(), hash_id_generate(csv_to_df().shape[0]), 'event_id'))
    # run import df to db
    insert_data()

    # insert_data_to_mysql(dict_of_df, 'df_event')
    # insert_data_to_mysql(dict_of_df, 'df_cat')
    # insert_data_to_mysql(dict_of_df, 'df_prod')
    # insert_data_to_mysql(dict_of_df, 'df_session')
    # insert_data_to_mysql(dict_of_df, 'df_hub')