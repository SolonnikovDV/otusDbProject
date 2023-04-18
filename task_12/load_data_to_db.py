import pandas as pd
from sqlalchemy import create_engine
import utils.config as cfg
from utils.config import get_time as current_time
from task_12.download_from_kaggle import csv_to_dict
import csv
from sqlalchemy.pool import NullPool

DB_NAME = 'csv_load_db'
USER =  cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT

PATH_TO_CSV = cfg.path_to_save_csv_task_12

def import_df_to_mysql(dict_of_df: dict, csv_name: str):

    # create connection to mysql db
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}', pool_recycle=3600, poolclass=NullPool)
    con = engine.connect()

    print(dict_of_df.keys())

    df = dict_of_df[csv_name]

    try:
        print(f'INFO: {current_time()} >> Uploading dataframe to database "{DB_NAME}" created successfully.')
        # df.to_sql(df_name, db_connection, if_exists='replace', index=False)
        # import df to mysql
        df.to_sql(name=csv_name,
                  con=con,
                  if_exists='replace',
                  index=False)
    except ValueError as vx:
        print(vx)
    except Exception as ex:
        print(ex)
    else:
        print(f'INFO: {current_time()} >> Table {DB_NAME} created successfully.')
    finally:
        con.close()

if __name__ == "__main__":
    import_df_to_mysql(csv_to_dict(PATH_TO_CSV), 'artists')
    import_df_to_mysql(csv_to_dict(PATH_TO_CSV), 'tracks')