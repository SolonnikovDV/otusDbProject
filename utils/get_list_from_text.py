import utils.config as cfg

'''
function return text with url link [text](url)
and convert it in markdown table unit

you need the text.txt file with fields names in next format:
<field 1>\n<field 2>\n<field 3> ... etc
'''


# read text file to the list of strings
def get_list_from_text(text_file) -> []:
    with open(f'{text_file}') as file:
        return file.read().split('\n')


# for Markdown table text+link
def concat_list_items_with_url(list_of_sting: [], url: str):
    for i, name in enumerate(list_of_sting):
        name = f'|{i + 1}. |[`{name}`]({url}{name}.sql)|'
        print(name)


if __name__ == '__main__':
    # print(concat_list_items_with_url(get_list_from_text('/path/to/text.txt'), cfg.URL))
    print(concat_list_items_with_url(get_list_from_text('/Users/dmitrysolonnikov/PycharmProjects/otusDbProject/task_3/connect_with_pySpark/table_names.txt'), cfg.URL))