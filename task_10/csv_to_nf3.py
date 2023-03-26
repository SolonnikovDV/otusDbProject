import pandas as pd

path_to_csv ='/Users/dmitrysolonnikov/PycharmProjects/otusDbProject/task_10/csv/shoe_prices.csv'

# changing df with replace fields 'Type', 'Color', 'Material', 'Price (USD)' to json
# adding id_keys for 'Brand', 'Gender', 'Size'
def csv_to_df() -> pd.DataFrame:

    # read csv file to df
    with open(path_to_csv) as df:
        df = pd.read_csv(df)
        df = df_to_json(df).drop(columns=['Type', 'Color', 'Material', 'Price (USD)', 'Model'])

        # add id_keys for 'Brand', 'Gender', 'Size', 'Model'
        # increase i by 1 because it starts from 0
        for i, val in enumerate(df['Brand'].unique()):
            df.loc[df['Brand'] == val, 'id_brand'] = int(1 + i)

        for i, val in enumerate(df['Gender'].unique()):
            df.loc[df['Gender'] == val, 'id_gender'] = int(1 + i)

        for i, val in enumerate(df['Size'].unique()):
            df.loc[df['Size'] == val, 'id_size'] = int(1 + i)

        for i, val in enumerate(df['Model_attribute'].unique()):
            df.loc[df['Model_attribute'] == val, 'id_model_attr'] = int(1 + i)

        # check sums of keys and unique values
        if df['Brand'].nunique() == df['id_brand'].nunique() \
                and df['Gender'].nunique() == df['id_gender'].nunique() \
                and df['Size'].nunique() == df['id_size'].nunique() \
                and df['Model_attribute'].nunique() == df['id_model_attr'].nunique():
                    print('passed')
        else:
            print('not passed')
    return df

# split main df for 4 df 'brand', 'gender', 'size', 'model'
# the model consider only unique values and other parameters joined under json as model attribute
def split_df(df: pd.DataFrame) -> dict:
    # 'iloc' set the positions of columns should stay in df, the other columns will be dropped from df exemplar
    df_brand = df.iloc[:, [4, 0]]
    df_gender = df.iloc[:, [5, 1]]
    df_size = df.iloc[:, [6, 2]]
    df_model_attr = df.iloc[:, [7, 3]]

    # sad all splited df in a list
    df_list = [df_brand, df_gender, df_size,  df_model_attr]
    # create list of keys
    key_list = ['df_brand', 'df_gender', 'df_size', 'df_model']
    # create empty dict
    df_dict = {}

    # delete repeatable values in df and push all splited df with keys into dict
    for key, val in enumerate(df_list):
        # print(val.drop_duplicates())
        # print(key)
        val = val.drop_duplicates().reset_index(drop=True, inplace=False, col_level=0, col_fill='')
        df_dict.update({key_list[key]: val})
    print(df_dict['df_model'])


    return df_dict


def df_to_json(df: pd.DataFrame):
    df_f = df.drop(columns=['Brand', 'Size', 'Gender'])
    df['Model_attribute']= df_f.apply(lambda x: x.to_json(), axis=1)
    return df




if __name__ =='__main__':
    # csv_to_df()
    split_df(csv_to_df())