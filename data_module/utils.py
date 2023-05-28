import yaml
import os
import csv
import vk

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


def get_params(*args):
    settings_path = os.path.join(get_root_path(), "settings.yaml")
    stream = open(settings_path, 'r')
    dictionary = yaml.load(stream, Loader=Loader)
    return [dictionary[val] for val in args]


def get_data(p_name: str):
    input_path = os.path.join(get_root_path(), "data_input")
    data_path = os.path.join(input_path, p_name)
    with open(data_path, newline='') as file:
        ids = csv.reader(file, delimiter=',')
        for row in ids:
            yield row


def get_root_path():
    current_folder = os.getcwd()
    return current_folder


def save_data():
    pass


def get_api(token: str, version: str):
    """Возвращает API, по токену и версии API"""
    p_api = vk.API(access_token=token, v=version)
    return p_api
