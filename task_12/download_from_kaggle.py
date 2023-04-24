import os
import sys, time, threading

import pandas as pd
from kaggle.api.kaggle_api_extended import KaggleApi
from os import walk
from utils import config as cfg

dataset = 'yamaerenay/spotify-dataset-19212020-600k-tracks'
# path_to_save = 'datasets/iris'
# file_name = 'Iris.csv'
PATH_TO_CSV = cfg.path_to_save_csv_task_12

KAGGLE_USERNAME = cfg.KAGGLE_USERNAME
KAGGLE_KEY = cfg.KAGGLE_KEY


# API get dataset files from Kaggle using method ```dataset_download_files()``` as zip archive
# set in counsrtuctor of method ```unzip=True``` to unpack downloaded zip archive
def get_data_from_api(dataset: str, path_to_save_csv: str):
    os.environ['KAGGLE_USERNAME'] = KAGGLE_USERNAME
    os.environ['KAGGLE_KEY'] = KAGGLE_KEY

    api = KaggleApi()
    api.authenticate()

    file_list: list = []
    exit: bool = False

    while exit == False:

        for (dirpath, dirnames, filenames) in walk(f'{PATH_TO_CSV}'):
            file_list.extend(filenames)

            if len(file_list) == 0:
                print('download process...')
                api.dataset_download_files(dataset, path_to_save_csv, unzip=True)

                for (dirpath, dirnames, filenames) in walk(f'{PATH_TO_CSV}'):
                    file_list.extend(filenames)
                    print(f'     ...download complete\n             total downloaded files: {file_list}')
                exit = True

            else:
                break


# select files by extension and adding to a list[]
def get_files_in_dir(file_extension: str):
    file_list: list = []
    file_list_with_extension: list = []

    # search for files in a dir
    for (dirpath, dirnames, filenames) in walk(f'{PATH_TO_CSV}'):
        file_list.extend(filenames)

        for file in file_list:
            if file.split('.')[1] == f'.{file_extension}':
                file_list_with_extension.extend(file)


def csv_to_dict(path_to_csv: str) -> {}:
    file_list: list = []
    file_list_with_extention: list = []
    file_extension: str = 'csv'
    dict_of_df: dict = {}

    for (dirpath, dirnames, filenames) in walk(f'{PATH_TO_CSV}'):
        file_list.extend(filenames)

        for file in file_list:
            if file.split('.')[1] == f'{file_extension}':
                file_list_with_extention.append(file)

                with open(f'{path_to_csv}/{file}') as csv_file:
                    df = pd.read_csv(csv_file, engine='pyarrow')
                    dict_of_df.update({file.split('.')[0]: df})

    return dict_of_df


if __name__ == '__main__':
    get_data_from_api(dataset, PATH_TO_CSV)
    # get_files_in_dir('csv')
    print(csv_to_dict(PATH_TO_CSV).head(1))
    ...
