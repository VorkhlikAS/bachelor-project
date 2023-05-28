from utils import get_params, get_data, get_api
from time import sleep
import psycopg2
import vk

filename = "data.csv"  # TODO: replace this with dynamic pathname
table_cols = [
    # user_data_id SERIAL,
    "id",
    "first_name",
    "last_name",
    # "can_access_closed",  # Возможность просмотра пользователя в друзьях со статусом is_closed=1
    "is_closed",
    "activities",
    "about",
    "blacklisted",
    # "blacklisted_by_me",  # Нахождение в черном списке текущего пользователя
    "books",
    "bdate",
    # "can_be_invited_group",  # Может ли текущий пользователь ...
    # "can_post",
    # "can_see_all_posts",
    # "can_see_audio",
    # "can_send_friend_request",
    # "can_write_private_message",
    "career",
    # "common_count", # Общие друзья с тек. пользователем
    "connections",
    "contacts",
    "city",
    "country",
    # "crop_photo",
    "domain",
    "education",
    "exports",
    "followers_count",
    # "friend_status",  # Статус заявки в друзья
    "has_photo",
    "has_mobile",
    "home_town",
    # "photo_100",
    # "photo_200",
    # "photo_200_orig",
    # "photo_400_orig",
    # "photo_50",
    "sex",
    "site",
    "schools",
    "screen_name",
    "status",
    "verified",
    "games",
    "interests",
    # "is_favorite",  # В закладках у тек. аккаунта
    # "is_friend",  # В друзьях текущего пользователя
    # "is_hidden_from_feed", # Скрыт из ленты пользователя
    # "last_seen",
    "maiden_name",
    "military",
    "movies",
    "music",
    "nickname",
    "occupation",
    # "online", # Зависит от времени
    "personal",
    # "photo_id",
    # "photo_max",
    # "photo_max_orig",
    "quotes",
    "relation",
    "relatives",
    "timezone",
    "tv",
    "universities"
]


def users_get(p_token: str, p_version: str, p_fields: list[str]):
    result = []
    api = get_api(p_token, p_version)
    users = get_data(filename)
    for user in users:
        result.append(api.users.get(user_ids=user[0], fields=p_fields))
        sleep(0.3)
    return result


def main():
    token, version, user_fields = get_params("token", "version", "fields")
    res = users_get(token, version, user_fields)
    print(res)

    fin = []

    for user in res:
        temp = []
        print(user[0].items())
        for i, col in enumerate(table_cols):
            if col in user[0]:
                print(i, col, user[0][col])
                temp.append(str(user[0][col]))
            else:
                print(f'{i} Missing: {col}')
                temp.append('')
        fin.append(temp)

    template = 'insert into dev_bot.user_data(' \
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
               'universities)' \
               'values({run_id}, {load_id},%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)'

    try:
        conn = psycopg2.connect(dbname='bot_db', user='bot_user', password='bot_detector', host='localhost')
        cursor = conn.cursor()
        cursor.execute(f'SELECT * FROM dev_bot.write_log(\'{"INSERT"}\', \'{"python_test"}\')')

        print(len(fin), fin)
        cursor.execute(f'SELECT * FROM dev_bot.create_run(\'python_test\')')
        run_id = cursor.fetchall()[0][0]
        cursor.execute(f'SELECT * FROM dev_bot.create_load({run_id})')
        load_id = cursor.fetchall()[0][0]
        cursor.executemany(template.format(run_id=run_id, load_id=load_id), fin)

        cursor.close()
        conn.commit()
        conn.close()
    except Exception as e:
        print('Error:', e)


if __name__ == "__main__":
    main()
