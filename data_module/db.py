import psycopg2  # Импортируем модуль psycopg2 для работы с PostgreSQL
from data_module.utils import get_params  # Импортируем функцию get_params из модуля data_module.utils


# Шаблон SQL-запроса для вставки данных в таблицу user_data
INSERT_U_DATA_TEMPLATE = 'insert into dev_bot.user_data(' \
               'run_id,' \
               'load_id,' \
               'id,' \
               'first_name,' \
               'last_name,' \
               'is_closed,' \
               'activities,' \
               'about,' \
               'blacklisted,' \
               'books,' \
               'bdate,' \
               'career,' \
               'connections,' \
               'contacts,' \
               'city,' \
               'country,' \
               'domain,' \
               'education,' \
               'exports,' \
               'followers_count,' \
               'has_photo,' \
               'has_mobile,' \
               'home_town,' \
               'sex,' \
               'site,' \
               'schools,' \
               'screen_name,' \
               'status,' \
               'verified,' \
               'games,' \
               'interests,' \
               'maiden_name,' \
               'military,' \
               'movies,' \
               'music,' \
               'nickname,' \
               'occupation,' \
               'personal,' \
               'quotes,' \
               'relation,' \
               'relatives,' \
               'timezone,' \
               'tv,' \
               'universities,' \
               'is_bot,' \
               'fol_cnt,' \
               'frn_cnt,' \
               'wll_cnt,' \
               'pht_cnt,' \
               'grp_cnt)' \
               'values(  {run_id}, ' \
                         '{load_id},' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s,' \
                         '%s)'


def get_connection():
    """
    Возвращает подключение к БД
    """
    try:
        dbname, user, password, host = get_params("dbname", "user", "password", "host")  # Получаем параметры подключения к БД
        conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host)  # Устанавливаем соединение с БД
        print(f'DEBUG: {conn}')
        return conn  # Возвращаем соединение
    except Exception as e:
        print(f'ERROR: {e}')
        return f"Database not responding... {e}"


def write_log(action: str, message: str):
    """
    Делает запись в LOG
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор
    cursor.execute(f'SELECT * FROM dev_bot.write_log(\'{action}\', \'{message}\')')  # Выполняем запрос на запись лога
    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение


def create_run(run_name):
    """
    Возвращает ID нового расчета
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор
    try:
        cursor.execute(f'SELECT * FROM dev_bot.create_run(\'{run_name}\')')  # Выполняем запрос на создание запуска
        run_id = cursor.fetchall()[0][0]  # Получаем идентификатор созданного запуска
    except Exception as e:
        print(e)
        run_id = None
    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение

    return run_id


def create_load(run_id):
    """
    Возвращает ID новой загрузки
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор
    try:
        cursor.execute(f'SELECT * FROM dev_bot.create_load({run_id})')  # Выполняем запрос на создание загрузки
        load_id = cursor.fetchall()[0][0]  # Получаем идентификатор созданной загрузки
    except Exception as e:
        print(e)
        load_id = None
    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение

    return load_id


def get_runs():
    """
    Возвращает список расчетов с информацией о статусе и ID
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор
    try:
        cursor.execute(f'SELECT * FROM dev_bot.get_runs()')  # Выполняем запрос на получение списка запусков
        runs = cursor.fetchall()  # Получаем список запусков
    except Exception as e:
        print(e)
        runs = None
    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение

    return runs


def set_status(run_id, status):
    """
    Устанавливает указанный статус расчета по ID
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор
    cursor.execute(f'SELECT dev_bot.set_run_status({run_id}, {status})')  # Выполняем запрос на установку статуса запуска
    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение


def load_user_data(run_id, load_id, data):
    """
    Загружает данные пользователей по ID расчета и ID загрузки
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор

    write_log('INSERT', f'server: user_data, {run_id}:{load_id}')  # Записываем лог о вставке данных
    cursor.executemany(INSERT_U_DATA_TEMPLATE.format(run_id=run_id, load_id=load_id), data)  # Выполняем массовую вставку данных

    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение


def delete_run(run_id):
    """
    Удаляет расчет по его ID
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор

    write_log('DELETE', f'server: run, {run_id}')  # Записываем лог об удалении запуска
    cursor.execute(f'SELECT dev_bot.delete_run({run_id})')  # Выполняем запрос на удаление запуска

    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение


def get_user_data(run_id):
    """
    Выгружает данные пользователей по ID расчета
    """
    conn = get_connection()  # Получаем соединение с БД
    cursor = conn.cursor()  # Создаем курсор
    try:
        cursor.execute(f'SELECT * FROM dev_bot.get_user_data({run_id})')  # Выполняем запрос на получение данных пользователя
        data = cursor.fetchall()  # Получаем данные пользователя
    except Exception as e:
        print(e)
        data = None
    cursor.close()  # Закрываем курсор
    conn.commit()  # Фиксируем изменения
    conn.close()  # Закрываем соединение

    return data
