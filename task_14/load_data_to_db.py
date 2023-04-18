from dask.diagnostics import ProgressBar
import utils.config as cfg
from download_from_kaggle import csv_to_dict


DB_NAME = 'csv_load_db'
USER = cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT

PATH_TO_CSV = cfg.path_to_save_csv_task_14


def import_dask_to_mysql(dict_: dict, table: str):
    # get df from dictionary from ```csv_to_dict(path_to_csv: str) -> {}```
    dd = dict_[table]

    # print(dd.head(5))

    to_sql_uri = f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}'

    # setup of ProgressBar for dask batches uploading
    pbar = ProgressBar()
    pbar.register()

    # setup of partitional upload dask dataFrame
    i = 0
    for i in range(dd.npartitions):
        partition = dd.get_partition(i)
        if i == 0:
            partition.to_sql(table, uri=to_sql_uri, if_exists='replace', index=False)
        if i > 0:
            partition.to_sql(table, uri=to_sql_uri, if_exists='append', index=False)
        i += 1


if __name__ == '__main__':
    import_dask_to_mysql(csv_to_dict(PATH_TO_CSV), 'steam_reviews')