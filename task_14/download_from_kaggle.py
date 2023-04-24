import os
import uuid

import pandas as pd
from dask import dataframe as dd
from kaggle.api.kaggle_api_extended import KaggleApi
from os import walk

from tqdm import tqdm

from utils import config as cfg

dataset = 'najzeko/steam-reviews-2021'
PATH_TO_CSV = cfg.path_to_save_csv_task_14

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


# func go throw the dir with .csv and split all csv file by a dot '.'
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


# func go throw the dir with .csv and split all csv file by a dot '.'
# after that we append name of csv as a key and df as a value
def csv_to_dict(path_to_csv: str) -> {}:
    file_list: list = []
    file_list_with_extension: list = []
    file_extension: str = 'csv'
    dict_of_df: dict = {}

    print('start read csv')
    # go throw dir with downloaded files and find files with .csv extensions
    for (dirpath, dirnames, filenames) in walk(f'{PATH_TO_CSV}'):
        file_list.extend(filenames)
        # split names of csv files without extensions
        for file in file_list:
            if file.split('.')[1] == f'{file_extension}':
                file_list_with_extension.append(file)
                # append key - value into dictionary
                df = dd.read_csv(f'{path_to_csv}{file}',
                                 engine='python',  escapechar="\n", on_bad_lines="skip", encoding='utf-8',
                                 dtype={'Unnamed: 0': 'object',
                                        'author.num_games_owned': 'object',
                                        'author.num_reviews': 'object',
                                        'author.steamid': 'object',
                                        'review_id': 'string',
                                        'timestamp_created': 'object',
                                        'votes_funny': 'object',
                                        'votes_helpful': 'object',
                                        'app_id': 'object',
                                        'comment_count': 'object',
                                        'timestamp_updated': 'object',
                                        'weighted_vote_score': 'object',
                                        'author.last_played': 'object'
                                        }).drop(['Unnamed: 0',
                                                 'recommended',
                                                 'votes_helpful',
                                                 'votes_funny',
                                                 'weighted_vote_score',
                                                 'comment_count',
                                                 'steam_purchase',
                                                 'received_for_free',
                                                 'written_during_early_access',
                                                 'author.num_games_owned',
                                                 'author.num_reviews',
                                                 'author.playtime_last_two_weeks',
                                                 'author.playtime_at_review'],
                                                axis=1)
                df['author.last_played'] = dd.to_datetime(df['author.last_played'], unit='s')
                dict_of_df.update({file.split('.')[0]: df})

        print('end read csv')

    return dict_of_df


if __name__ == '__main__':
    print(csv_to_dict(PATH_TO_CSV)['steam_reviews'].head(1))
    ...
