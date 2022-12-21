from datetime import datetime
import psycopg2
import utils.config as cfg
import pandas as pd

DATA_TIME = datetime.now()
HOST = cfg.HOST
PORT = cfg.PORT
DBNAME = cfg.DBNAME
USER = cfg.USER
PASSWORD = cfg.PASSWORD

# create connection to PostgreSql
def create_connection_to_psql(host, port, dbname, user, password):
    conn = psycopg2.connect(f"""
            host={host}
            port={port}
            dbname={dbname}
            user={user}
            password={password}
            """)
    conn.autocommit = True
    with conn.cursor() as cur:
        cur.execute('SELECT version()')
        print(f'[INFO] : {DATA_TIME} Server version : \n{cur.fetchone()}')
        return conn


# return data base schema info
def db_info():
    conn = create_connection_to_psql(HOST, PORT, DBNAME, USER, PASSWORD)
    cursor = conn.cursor()

    cursor.execute("""SELECT table_schema, table_name
                      FROM information_schema.tables
                      WHERE table_schema != 'pg_catalog'
                      AND table_schema != 'information_schema'
                      AND table_type='BASE TABLE'
                      ORDER BY table_schema, table_name;""")
    df = pd.DataFrame(cursor.fetchall(), columns=['Schema_name', 'Table_name'])
    print(f'Data base {DBNAME} info:\n{df}\n{df.count()}')
    # print(df.count())

    cursor.close()


if __name__ == '__main__':
    db_info()