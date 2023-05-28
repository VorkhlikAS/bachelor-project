# Импорт необходимых библиотек и модулей
import os  # для взаимодействия с файловой системой
from flask import Flask, render_template, request, redirect, url_for, send_from_directory  # Flask - фреймворк для веб-приложений
from data_module.utils import get_root_path  # функция для получения корневого пути проекта
from data_module.vk_parse import get_users_by_file  # функция для обработки данных пользователей из файла
import data_module.ml as ml  # модуль машинного обучения
import data_module.db as db  # модуль для работы с базой данных
from time import sleep  # для создания задержек

# Создание экземпляра веб-приложения
app = Flask(__name__)

# Определение корневого пути проекта
PROJECT_FOLDER = get_root_path()

# Определение маршрута для главной страницы приложения
@app.route('/')
def index():
    """
    Это функция отображает главную страницу веб-приложения.
    """
    runs = db.get_runs()  # получение всех записей (запусков)
    initial_run_id = request.args.get('new_run_id')  # получение id нового запуска из запроса
    initial_run_name = None  # инициализация имени нового запуска
    for ln in runs:  # перебор всех запусков
        if str(ln[0]) == str(initial_run_id):  # если id запуска совпадает с id нового запуска
            initial_run_name = ln[1]  # то записываем имя этого запуска

    # Рендерим шаблон и передаем туда все запуски и имя нового запуска
    return render_template('upload.html', runs=runs, initial_run_name=initial_run_name)


# Определение маршрута для загрузки CSV-файла
@app.route('/upload/<string:runId>', methods=['POST'])
def upload_csv(runId):
    """
    Эта функция обрабатывает загрузку CSV-файла и последующую обработку данных.
    """
    csv_file = request.files['csv_file']  # получаем файл из запроса
    if not csv_file:  # если файл не передан
        return "No file uploaded."  # то возвращаем сообщение об ошибке
    else:  # иначе
        data_input_path = os.path.join(get_root_path(), "data_input")  # формируем путь к директории для входных данных
        csv_file.save(os.path.join(data_input_path, csv_file.filename))  # сохраняем файл в директорию

        user_data = get_users_by_file(csv_file.filename)  # получаем данные пользователей из файла

        db.set_status(runId, 2)  # устанавливаем статус запуска
        load_id = db.create_load(runId)  # создаем загрузку в базе данных
        db.load_user_data(runId, load_id, user_data)  # загружаем данные пользователей в базу данных
        os.remove(os.path.join(data_input_path, csv_file.filename))  # удаляем исходный файл
        db.write_log('DELETE', 'server: deleting source file')  # записываем лог об удалении файла
        # Возвращаемся на главную страницу с передачей id нового запуска
        return redirect(url_for('index', new_run_id=runId))


# Определение маршрута для создания нового запуска
@app.route('/create_run', methods=['POST'])
def create_run():
    """
    Эта функция создает новый запуск (run).
    """
    run_name = request.form['myInput']  # получаем имя нового запуска из формы
    new_run_id = db.create_run(run_name)  # создаем новый запуск в базе данных
    # Возвращаемся на главную страницу с передачей id нового запуска
    return redirect(url_for('index', new_run_id=new_run_id))

# Определение маршрута для создания и обучения модели машинного обучения
@app.route('/create_model/<string:runId>', methods=['POST'])
def create_model(runId):
    """
    Эта функция создает модель машинного обучения и обучает ее.
    """
    model = request.form['model-type']  # получаем тип модели из формы
    res = ml.train(runId, model)  # обучаем модель

    if res != 'success': # проверяем успешность обучения модели
        return res # отправляем сообщение о некорректных данных
    db.set_status(runId, 3)  # устанавливаем статус запуска
    db.write_log('CREATE', f'server: creating {model}')  # записываем лог о создании модели
    # Возвращаемся на главную страницу с передачей id нового запуска
    return redirect(url_for('index', new_run_id=runId))


# Определение маршрута для пропуска этапа создания модели
@app.route('/skip/<string:runId>', methods=['POST'])
def skip(runId):
    """
    Эта функция позволяет пропустить этап создания модели.
    """
    db.set_status(runId, 2)  # устанавливаем статус запуска
    db.set_status(runId, 3)  # устанавливаем статус запуска
    # Возвращаемся на главную страницу с передачей id нового запуска
    return redirect(url_for('index', new_run_id=runId))


# Определение маршрута для удаления запуска
@app.route('/delete/<string:runId>', methods=['POST'])
def delete(runId):
    """
    Эта функция удаляет запуск (run) и связанные с ним файлы.
    """
    db.delete_run(runId)  # удаляем запуск из базы данных

    for dir, file in {
        'models': f'model_{runId}.sav',  # модель
        'data_output': f'res_{runId}.csv'  # результаты
    }.items():
        path = os.path.join(get_root_path(), dir)  # формируем путь к директории
        filepath = os.path.join(path, file)  # формируем полный путь к файлу
        # Если файл существует, то удаляем его
        if os.path.isfile(filepath):
            os.remove(filepath)
        else:  # Иначе выводим сообщение об отсутствии файла
            print(f'DEBUG: {file} doesn\'t exist')

    path = os.path.join(get_root_path(), 'static', 'images')  # формируем путь к директории для изображений
    filepath = os.path.join(path, f'plot_{runId}.png')  # формируем полный путь к файлу с изображением
    # Если файл существует, то удаляем его
    if os.path.isfile(filepath):
        os.remove(filepath)
    else:  # Иначе выводим сообщение об отсутствии файла
        print(f'DEBUG: {filepath} doesn\'t exist')

    # Возвращаемся на главную страницу
    return redirect(url_for('index'))


# Определение маршрута для загрузки тестовых данных и выполнения предсказаний
@app.route('/upload_test/<string:runId>', methods=['POST'])
def upload_test(runId):
    """
    Эта функция обрабатывает загрузку тестовых данных и выполнение предсказаний моделью.
    """
    csv_file = request.files['csv_file']  # получаем файл из запроса
    if not csv_file:  # если файл не передан
        return "No file uploaded."  # то возвращаем сообщение об ошибке
    else:  # иначе
        db.write_log('INSERT', f'server: loading test')  # записываем лог о загрузке тестовых данных
        data_input_path = os.path.join(get_root_path(), "data_input")  # формируем путь к директории для входных данных
        csv_file.save(os.path.join(data_input_path, csv_file.filename))  # сохраняем файл в директорию

        user_data = get_users_by_file(csv_file.filename, test=1)  # получаем данные пользователей из файла

        db.set_status(runId, 4)  # устанавливаем статус запуска
        load_id = db.create_load(runId)  # создаем загрузку в базе данных
        db.load_user_data(runId, load_id, user_data)  # загружаем данные пользователей в базу данных
        os.remove(os.path.join(data_input_path, csv_file.filename))  # удаляем исходный файл
        db.write_log('DELETE', 'server: deleting source file')  # записываем лог об удалении файла

        ml.predict(runId)  # выполняем предсказание моделью
        db.set_status(runId, 5)  # устанавливаем статус запуска

        # Возвращаемся на главную страницу с передачей id нового запуска
        return redirect(url_for('index', new_run_id=runId))


# Маршрут для страницы успеха загрузки
@app.route('/success')
def success():
    """
    Возвращает сообщение о успешной загрузке CSV файла.
    """
    return "CSV file uploaded successfully"

# Маршрут для скачивания файла
@app.route('/download/<string:runId>', methods=['POST'])
def download(runId):
    """
    Отправляет файл с результатами для скачивания.
    """
    data_output_path = os.path.join(get_root_path(), 'data_output')
    filename = f'res_{runId}.csv'
    print(f'DEBUG: download res_{runId}.csv')
    return send_from_directory(directory=data_output_path,
                               path=filename,
                               as_attachment=True)

# Запускает приложение, если скрипт запущен напрямую
if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=5000)
