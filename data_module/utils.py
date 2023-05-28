import yaml  # Импортируем модуль yaml для работы с YAML-файлами
import os  # Импортируем модуль os для работы с операционной системой
import csv  # Импортируем модуль csv для работы с CSV-файлами
import vk  # Импортируем модуль vk для работы с VK API

try:
    from yaml import CLoader as Loader  # Импортируем CLoader из модуля yaml, если доступен (для более быстрой загрузки YAML-файлов)
except ImportError:
    from yaml import Loader  # Импортируем Loader из модуля yaml, если CLoader не доступен


def get_params(*args):
    """
    Возвращает параметры из settings.yaml по именам
    """
    settings_path = os.path.join(get_root_path(), "settings.yaml")  # Путь к YAML-файлу с настройками
    stream = open(settings_path, 'r')  # Открываем файл на чтение
    dictionary = yaml.load(stream, Loader=Loader)  # Загружаем данные из YAML-файла в словарь
    return [dictionary[val] for val in args]  # Возвращаем значения параметров по их именам


def get_data(p_name: str):
    """
    Возвращает строки читаемые из CSV-файла
    """
    input_path = os.path.join(get_root_path(), "data_input")  # Путь к папке с входными данными
    data_path = os.path.join(input_path, p_name)  # Путь к CSV-файлу
    with open(data_path, newline='') as file:  # Открываем CSV-файл на чтение
        ids = csv.reader(file, delimiter=',')  # Создаем объект csv.reader для чтения данных
        for row in ids:
            yield row  # Возвращаем каждую строку данных из CSV-файла в виде генератора


def get_root_path():
    """
    Возвращает путь к корневой папке приложения
    """
    current_folder = os.getcwd()  # Получаем текущую рабочую папку
    return current_folder  # Возвращаем путь к текущей папке


def get_api(token: str, version: str):
    """
    Возвращает API, по токену и версии API
    """
    p_api = vk.API(access_token=token, v=version)  # Инициализируем объект API с помощью токена и версии API
    return p_api  # Возвращаем объект API
