from data_module.utils import get_root_path  # Импортируем функцию get_root_path из модуля utils в пакете data_module
import data_module.db as db  # Импортируем модуль db из пакета data_module и называем его db
import pandas as pd  # Импортируем модуль pandas и называем его pd
from sklearn import model_selection  # Импортируем модуль model_selection из пакета sklearn
from sklearn import svm, tree  # Импортируем классы svm и tree из пакета sklearn
from sklearn.ensemble import RandomForestClassifier  # Импортируем класс RandomForestClassifier из пакета sklearn.ensemble
import pickle  # Импортируем модуль pickle для сохранения моделей
import os  # Импортируем модуль os для работы с файлами
from matplotlib import pyplot as plt  # Импортируем функцию pyplot из модуля matplotlib и называем его plt
import numpy as np  # Импортируем модуль numpy и называем его np


MODELS = {
    "svm": svm.SVC(probability=True),  # Создаем объект svm.SVC с аргументом probability=True и добавляем его в словарь MODELS
    "dt": tree.DecisionTreeClassifier(),  # Создаем объект tree.DecisionTreeClassifier и добавляем его в словарь MODELS
    "rf": RandomForestClassifier(n_estimators=50)  # Создаем объект RandomForestClassifier с аргументом n_estimators=50 и добавляем его в словарь MODELS
}


def predict(run_id):
    print(f'DEBUG: predicting {run_id}')
    df = db.get_user_data(run_id)  # Получаем данные пользователя с помощью функции get_user_data из модуля db в пакете data_module
    df = pd.DataFrame(df)  # Преобразуем полученные данные в объект DataFrame из модуля pandas и называем его df
    
    X = df.loc[:, 1:40]  # Выбираем столбцы с индексами от 1 до 40 из DataFrame df и присваиваем их переменной X

    print(X.head())

    filename = f'model_{run_id}.sav'
    model_path = os.path.join(get_root_path(), "models")  # Создаем путь к папке models с помощью функции get_root_path из модуля utils
    filepath = os.path.join(model_path, filename)  # Создаем полный путь к файлу модели
    if os.path.isfile(filepath):  # Проверяем, существует ли файл модели по указанному пути
        loaded_model = pickle.load(open(filepath, 'rb'))  # Загружаем модель из файла
    else:
        filepath = os.path.join(model_path, 'the_model.sav')  # Если файл модели не найден, загружаем резервную модель
        loaded_model = pickle.load(open(filepath, 'rb'))

    y = loaded_model.predict(X)  # Прогнозируем значения y с помощью загруженной модели
    res = pd.DataFrame(y)  # Создаем DataFrame из предсказанных значений
    print(res.head())
    res = pd.concat([df.loc[:, 0], res], axis=1, keys=['id', 'is_bot'])  # Объединяем DataFrame df с предсказанными значениями res
    print(f'DEBUG: saving {run_id}')
    filename = f'res_{run_id}.csv'
    data_output_path = os.path.join(get_root_path(), "data_output")  # Создаем путь к папке data_output с помощью функции get_root_path из модуля utils
    res.to_csv(os.path.join(data_output_path, filename), header=False, index=False)  # Сохраняем результат в CSV-файл

    bot_class = np.array(y).astype(float)  # Преобразуем предсказанные значения в массив типа float

    if type(loaded_model) == type(MODELS['dt']):  # Проверяем, является ли загруженная модель моделью DecisionTreeClassifier
        probs = loaded_model.predict_proba(X)  # Если да, получаем вероятности принадлежности классам с помощью метода predict_proba
    else: 
        probs = loaded_model.predict_proba(X)[:, 1]  # Иначе получаем вероятности принадлежности к положительному классу

    print(bot_class)
    print(probs)

    plt.figure(figsize=(15, 7))  # Создаем новую фигуру для построения графика
    if 0 in bot_class:  # Если в предсказанных значениях есть 0
        plt.hist(probs[bot_class == 0], bins=50, label='Человек', range=[0.0, 1.0])  # Строим гистограмму для вероятностей человека
    if 1 in bot_class:  # Если в предсказанных значениях есть 1
        plt.hist(probs[bot_class == 1], bins=50, label='Бот', alpha=0.7, color='r', range=[0.0, 1.0])  # Строим гистограмму для вероятностей бота
    plt.xlabel('Уверенность модели', fontsize=25)  # Задаем подпись оси x
    plt.ylabel('Количество', fontsize=25)  # Задаем подпись оси y
    plt.legend(fontsize=15)  # Добавляем легенду
    plt.tick_params(axis='both', labelsize=25, pad=5)  # Задаем параметры делений на осях

    filename = f'plot_{run_id}.png'
    plot_path = os.path.join(get_root_path(), "static", "images")  # Создаем путь к папке images внутри папки static с помощью функции get_root_path из модуля utils
    plt.savefig(os.path.join(plot_path, filename), bbox_inches='tight')  # Сохраняем график в файл


def train(run_id, model_type):
    print(f'DEBUG: training {run_id}')
    df = db.get_user_data(run_id)  # Получаем данные пользователя с помощью функции get_user_data из модуля db в пакете data_module
    df = pd.DataFrame(df)  # Преобразуем полученные данные в объект DataFrame из модуля pandas и называем его df

    Y = df.loc[:, 41]  # Выбираем столбец с индексом 41 (целевая переменная) из DataFrame df и присваиваем его переменной Y
    X = df.loc[:, 1:40]  # Выбираем столбцы с индексами от 1 до 40 из DataFrame df и присваиваем их переменной X
    test_size = 0.33  # Задаем размер тестовой выборки
    seed = 7  # Задаем семя для генерации случайных чисел

    print(X[X.applymap(lambda x: isinstance(x, str)).any(axis=1)])  # Выводим строки, содержащие значения, которые не являются числами

    X_train, X_test, Y_train, Y_test = model_selection.train_test_split(X, Y, test_size=test_size, random_state=seed)  # Разделяем данные на обучающую и тестовую выборки
    model = MODELS[model_type]  # Выбираем модель по заданному типу из словаря MODELS
    try:
        model.fit(X_train, Y_train)  # Обучаем модель на данных пользователей
    except Exception as e:
        return str('Загруженные данные не подходят для обучения!')

    filename = f'model_{run_id}.sav'
    model_path = os.path.join(get_root_path(), "models")  # Создаем путь к папке models с помощью функции get_root_path из модуля utils
    pickle.dump(model, open(os.path.join(model_path, filename), 'wb'))  # Сохраняем модель в файл
    result = model.score(X_test, Y_test)  # Оцениваем модель на тестовых данных
    print(f'DEBUG: score: {result}')
    print(f'DEBUG: saving {filename}')

    return 'success'


# if __name__ == "__main__":
#     train(112, 'dt')
#     train(112, 'svm')
#     train(112, 'rf')
