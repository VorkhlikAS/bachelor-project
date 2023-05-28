import psycopg2
from data_module.utils import get_params

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
    try:
        dbname, user, password, host = get_params("dbname", "user", "password", "host")
        conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host)
        print(f'DEBUG: {conn}')
        return conn
    except Exception as e:
        print(f'ERROR: {e}')
        return f"Database not responding... {e}"


def write_log(action: str, message: str):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(f'SELECT * FROM dev_bot.write_log(\'{action}\', \'{message}\')')
    cursor.close()
    conn.commit()
    conn.close()


def create_run(run_name):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(f'SELECT * FROM dev_bot.create_run(\'{run_name}\')')
        run_id = cursor.fetchall()[0][0]
    except Exception as e:
        print(e)
        run_id = None
    cursor.close()
    conn.commit()
    conn.close()

    return run_id


def create_load(run_id):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(f'SELECT * FROM dev_bot.create_load({run_id})')
        load_id = cursor.fetchall()[0][0]
    except Exception as e:
        print(e)
        load_id = None
    cursor.close()
    conn.commit()
    conn.close()

    return load_id


def get_runs():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(f'SELECT * FROM dev_bot.get_runs()')
        runs = cursor.fetchall()
    except Exception as e:
        print(e)
        runs = None
    cursor.close()
    conn.commit()
    conn.close()

    return runs


def set_status(run_id, status):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(f'SELECT dev_bot.set_run_status({run_id}, {status})')
    cursor.close()
    conn.commit()
    conn.close()


def load_user_data(run_id, load_id, data):
    conn = get_connection()
    cursor = conn.cursor()

    write_log('INSERT', f'server: user_data, {run_id}:{load_id}')
    cursor.executemany(INSERT_U_DATA_TEMPLATE.format(run_id=run_id, load_id=load_id), data)

    cursor.close()
    conn.commit()
    conn.close()


def delete_run(run_id):
    conn = get_connection()
    cursor = conn.cursor()

    write_log('DELETE', f'server: run, {run_id}')
    cursor.execute(f'SELECT dev_bot.delete_run({run_id})')

    cursor.close()
    conn.commit()
    conn.close()


def get_user_data(run_id):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(f'SELECT * FROM dev_bot.get_user_data({run_id})')
        data = cursor.fetchall()
    except Exception as e:
        print(e)
        data = None
    cursor.close()
    conn.commit()
    conn.close()

    return data
