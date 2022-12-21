import utils.config as cfg

URL = cfg.URL

'''
function return text with url link [text](url)
and convert it in markdown table unit

you need the text.txt file with fields names in next format:
<field 1>\n<field 2>\n<field 3> ... etc
'''

def get_list_from_text(text_file):
    with open(f'{text_file}') as file:
        table_name = file.read().split('\n')
    for i, name in enumerate(table_name):
        name = f'|{i+1}. |[`{name}`]({URL}{name}.sql)|'
        return name




if __name__ == '__main__':
    print(get_list_from_text('table_names.txt'))