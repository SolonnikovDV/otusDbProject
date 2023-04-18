import time
import pandas as pd

import requests
from bs4 import BeautifulSoup
import urllib.request as urllib2
import ssl
import os
from utils import config as cfg

ext = 'iso'
url = 'https://github.com/levinmejia/Shopify-Product-CSVs-and-Images/blob/master/CSVs'
PATH_TO_CSV = cfg.path_to_save_csv_task_12


'''
csv are in next hrefs:
/levinmejia/Shopify-Product-CSVs-and-Images/blob/master/CSVs/Apparel.csv
/levinmejia/Shopify-Product-CSVs-and-Images/blob/master/CSVs/Bicycles.csv
/levinmejia/Shopify-Product-CSVs-and-Images/blob/master/CSVs/Fashion.csv
/levinmejia/Shopify-Product-CSVs-and-Images/blob/master/CSVs/SnowDevil.csv
/levinmejia/Shopify-Product-CSVs-and-Images/blob/master/CSVs/jewelry.csv
'''

def get_file_names_csv_from_url(url: str):
    file_names = {}
    # need to resolve problem with certificate
    # [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1123)
    context = ssl._create_unverified_context()

    page = urllib2.urlopen(url, context=context).read()
    soup = BeautifulSoup(page, features='html.parser')
    soup.prettify()

    for anchor in soup.findAll('a', href=True):
        split_str = anchor['href'].split('/')
        for item in split_str:
            if item == 'CSVs' and len(split_str) == 7:
                file_names.update({split_str[6]: f'{url}/{split_str[6]}'})
    print (file_names)

    return file_names


def download_csv_from_http(dict_ : dict):
    for key, val in dict_.items():
        response = requests.get(f'{val}')
        open(f'{PATH_TO_CSV}{key}', "wb").write(response.content)


if __name__ == '__main__':
    get_file_names_csv_from_url(url)
    # download_csv_from_http(get_file_names_csv_from_url(url))

