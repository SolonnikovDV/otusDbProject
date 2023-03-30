import pandas as pd
import time
import uuid
from tqdm import tqdm
from tqdm.auto import tqdm
from utils.get_time import current_time
from datetime import datetime

'''
as dataset was used 9Gb csv file from https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store 
'''
path_to_csv ='/Users/dmitrysolonnikov/PycharmProjects/otusDbProject/task_11/csv/2019-Nov.csv'

def csv_to_df() -> pd.DataFrame:
    # set option to see all columns in console
    pd.set_option('display.max_columns', None)

    # read csv file to df
    with open(path_to_csv) as csv_file:

        t0 = time.time()
        # engine="pyarrow" on pandas works faster even read csv with chunks or wright/read parquet
        # df = pd.read_csv(csv_file, engine="pyarrow")
        custom_date_parser = lambda x: datetime.strptime(x, "%Y-%d-%m %H:%M:%S")
        df = pd.read_csv(csv_file, nrows=30000000, parse_dates=['event_time'], date_parser=custom_date_parser)

        t1 = time.time()
        total = t1 - t0
        print(f'{total}') # 24.85 sec

        print(f'INFO : {current_time()} >> csv file raed successful')
        print(f'INFO : {current_time()} >> csv file total rows in csv {df.shape[0]}') # 67501979 total rows count

    return df


# devine df for tables using 'Star' db modeling pattern
# event_time, event_type, product_id, category_id, category_code, brand, price, user_id, user_session
def split_df(df: pd.DataFrame) -> dict:
    # 67501979 total rows count in unsplited dataframe

    # 'iloc' set the positions of columns should stay in df, the other columns will be dropped from df exemplar
    # category_id(key), category code
    df_cat = df.iloc[:, [3, 4]]

    # creating df of product_id(key) + brand + price
    df_prod = df.iloc[:, [2, 5, 6]]

    # user_session(key), user_id
    df_session = df.iloc[:, [8, 7]]

    # event_id(key), event_type, event_time
    df_event = df.iloc[:, [9, 1, 0]]

    # this table is the hub of all tables in DB
    # event_id(foreign key), product_id(foreign key), category_id(foreign key), user_session((foreign key)
    df_hub = df.iloc[:, [9, 8, 2, 3]]

    # sad all splited df in a list
    df_list = [df_event, df_cat, df_prod,  df_session, df_hub]
    # create list of keys
    key_list = ['df_event', 'df_cat', 'df_prod', 'df_session', 'df_hub']
    # create empty dict
    df_dict = {}

    tqdm.pandas(desc="drop duplicates / null rows progress bar!")
    # delete repeatable values in df and push all splited df with keys into dictionary
    for key, val in enumerate(tqdm(df_list)):
        # distinct values (val.columns[0] - name of column in a string type)
        val = val.drop_duplicates(subset=[val.columns[0]], keep="first",).progress_apply(lambda x: x**2)
        # drop 'is Null' rows from primary keys columns (val.columns[0] - name of column in a string type)
        val = val.dropna(subset=[val.columns[0]]).progress_apply(lambda x: x**2)
        df_dict.update({key_list[key]: val})

    return df_dict


# join columns of two dataframe
def insert_col_to_df(df: pd.DataFrame, list_of_values: [], name_of_col: str) -> pd.DataFrame:
    df_from_list = pd.DataFrame(list_of_values, columns=[name_of_col])
    df_joined = df.join(df_from_list[name_of_col])
    return df_joined


# creating dataframe and fill it with generated hash values
# also added progressbar for generating values and filling dataframe column
def hash_id_generate (count: int) -> []:
    list_of_hash = []

    print(f'INFO: {current_time()} >> start generating hash id')
    for i in tqdm(range(count)):
        i = uuid.uuid4()
        list_of_hash.append(i)
    print(f'INFO: {current_time()} >> Generation hash id complete')
    print(f'list length: {len(list_of_hash)}')
    return list_of_hash


if __name__ =='__main__':
    ...
    # csv_to_df()
    # split_df(insert_col_to_df(csv_to_df(), hash_id_generate(csv_to_df().shape[0]), 'event_id'))
    # print(insert_col_to_df(csv_to_df(), hash_id_generate(csv_to_df().shape[0]), 'event_id').head(5))
