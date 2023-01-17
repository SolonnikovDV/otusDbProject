from datetime import datetime
from urllib.request import urlopen, Request
import json
import ssl
from sqlalchemy import create_engine
import pandas as pd
from functools import lru_cache

import utils.config as cfg

# constants
DATA_TIME = datetime.now()
HOST = cfg.HOST_DML
PORT = cfg.PORT_DML
DBNAME = cfg.DBNAME_DML
USER = cfg.USER_DML
PASSWORD = cfg.PASSWORD_DML
API_KEY = cfg.API_KEY

# API links
API_NHL_TEAM = 'https://statsapi.web.nhl.com/api/v1/teams?expand=team.roster'


# load data from url to json
@lru_cache(maxsize=2)
def get_data_from_ulr(url: str) -> dict:
    # here we are solve problem with ssl certificate verify
    ssl._create_default_https_context = ssl._create_unverified_context
    # get data from url
    with urlopen(f'{url}', ) as response:
        data = json.loads(response.read().decode('utf-8'))
        # getting dataframe from nested json
        df = pd.json_normalize(data, 'teams')
        '''
        Here we need to get next dataframes:
        1. teams table (team.id, name, link, teamName, locationName,firstYearOfPlay, division.id, conference.id, ), 
        2. division table (division.id), 
        3. conference table (conference.id), 
        4. person table (team.id, person.id)
        '''
        # exploding nested dataframe
        df = pd.DataFrame(df, index=None).explode('roster.roster')
        # drop unusing fields
        df = df.drop(['abbreviation',
                      'shortName',
                      'officialSiteUrl',
                      'roster.link',
                      'active',
                      'venue.name',
                      'venue.timeZone.id',
                      'venue.timeZone.offset',
                      'venue.timeZone.tz',
                      'division.nameShort',
                      'division.abbreviation',
                      'division.link',
                      'conference.link',
                      'franchise.franchiseId',
                      'franchiseId',
                      'venue.link',
                      'venue.city',
                      'venue.id',
                      'franchise.teamName',
                      'franchise.link', ], axis=1)

        # pd.set_option('display.max_columns', None)

        # construct tables from dataframe
        # df_teams table
        df_teams = df[['id',
                       'name',
                       'link',
                       'teamName',
                       'locationName',
                       'firstYearOfPlay',
                       'division.id',
                       'conference.id', ]]\
            .reset_index(drop=True)\
            .drop_duplicates()

        # create df_division table
        df_division = df[['division.id',
                          'division.name']]\
            .reset_index(drop=True)\
            .drop_duplicates()

        # create df_conference table
        df_conference = df[['conference.id',
                            'conference.name']]\
            .reset_index(drop=True)\
            .drop_duplicates()

        # create df_person table
        df_person = df[['id',
                        'roster.roster']]\
            .rename(columns={'id': 'team.id'})\
            .reset_index(drop=True)

        # some of fields have a dict as values
        # decompose dict values in 'df_person' to columns
        # 1st level with 2 dict inside
        df_person = pd.concat([df_person.drop(['roster.roster'], axis=1),
                               df_person['roster.roster'].apply(pd.Series)], axis=1)
        # 1st dict 'person'
        df_person = pd.concat([df_person.drop(['person'], axis=1),
                               df_person['person'].apply(pd.Series),
                               df_person.drop(['position'], axis=1),
                               df_person['position'].apply(pd.Series)],
                              axis=1)
        # 2nd dict 'position'
        df_person = df_person.drop(['position'], axis=1)\
            .drop(['person'], axis=1).drop(['abbreviation'], axis=1)\
            .rename(columns={'code': 'position.code', 'name': 'position.name', 'type': 'position.type'})\
            .reset_index(drop=True)\
            .drop_duplicates()

        # collect dataframes into dict
        df_dict = {'df_teams': df_teams,
                   'df_division': df_division,
                   'df_conference': df_conference,
                   'df_person': df_person}

        return df_dict


# call dataframes from 'df_dict' and import them to db
def import_df_to_db(df_dict: dict):

    engine = create_engine(f'postgresql://{USER}:{PASSWORD}@localhost:5432/{DBNAME}')
    if True:
        for key in df_dict:
            df_dict[key].to_sql(key, engine, if_exists='replace')
        print(f'{DATA_TIME} >> Data import is successful')


if __name__ == '__main__':
    import_df_to_db(get_data_from_ulr(API_NHL_TEAM))

