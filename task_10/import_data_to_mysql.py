from sqlalchemy import create_engine
from csv_to_nf3 import csv_to_df, split_df
import utils.config as cfg

DB_NAME = cfg.DB_NAME
USER =  cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT

def insert_data_to_mysql(df_dict: dict, df_name: str):
    df = df_dict[f'{df_name}']
    print(df.head(5))
    print(df_dict['df_model'])

    # create connection to mysql db
    sql_engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}', pool_recycle=3600)
    db_connection = sql_engine.connect()

    try:
        df.to_sql(df_name, db_connection, if_exists='replace')
    except ValueError as vx:
        print(vx)
    except Exception as ex:
        print(ex)
    else:
        print("Table %s created successfully." % df_name)
    finally:
        db_connection.close()


if __name__ == '__main__':
    insert_data_to_mysql(split_df(csv_to_df()), 'df_brand')
    insert_data_to_mysql(split_df(csv_to_df()), 'df_gender')
    insert_data_to_mysql(split_df(csv_to_df()), 'df_size')
    insert_data_to_mysql(split_df(csv_to_df()), 'df_model')