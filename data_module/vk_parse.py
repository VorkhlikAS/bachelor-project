import vk
from data_module.utils import get_params, get_data, get_api
from time import sleep

ALL_COLS = [
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


def get_user_data(user_id: str, api: vk.session.API):
    """
    Возвращает данные пользователя по его ID
    """
    fields = get_params("fields")  # Получаем список полей из конфигурации
    try:
        result = api.users.get(user_ids=user_id, fields=fields[0])  # Запрашиваем данные пользователя по его ID и полям
        sleep(0.5)  # Пауза для соблюдения ограничений VK API
        return result
    except vk.exceptions.VkAPIError as e:
        print(f"VK API error occurred: {e}")  # Выводим сообщение об ошибке VK API
        return None

 
def get_users_by_file(filename: str, test: int = 0):
    """
    Возвращает данные о пользователях указанных в файле
    """
    token, version = get_params("token", "version")  # Получаем токен и версию API из конфигурации
    api = get_api(token=token, version=version)  # Получаем экземпляр API
    data = get_data(filename)  # Получаем данные о пользователях из файла
    api_result = []  # Результаты запросов к VK API

    for user in data:
        if test != 1:
            api_result.append([get_user_data(user[0], api), user[1]])  # Запрашиваем данные пользователя и добавляем их в api_result
        else:
            api_result.append([get_user_data(user[0], api), ''])  # Запрашиваем данные пользователя и добавляем их в api_result

    final = []  # Итоговый результат

    for user in api_result:
        temp = []  # Временное хранилище для данных пользователя
        print(f'DEBUG: items: {user[0][0].items()}')
        print(f'DEBUG: isbot = {user[1]}')
        long_id = user[0][0]['id']
        print(f'DEBUG: long id = {long_id}')
        closed = False  # Флаг, указывающий на закрытый профиль пользователя
        for i, col in enumerate(ALL_COLS):
            if col in user[0][0]:  # Проверяем наличие поля в данных пользователя
                if test != 1 and col == 'is_closed' and user[0][0][col] == 'True':  # Проверяем, является ли профиль закрытым
                    closed = True
                    break
                print(i, col, user[0][0][col])  # Выводим информацию о поле пользователя
                temp.append(str(user[0][0][col]))  # Добавляем значение поля во временное хранилище
            else:
                print(f'{i} Missing: {col}')  # Выводим сообщение о пропущенном поле
                temp.append('')  # Добавляем пустое значение во временное хранилище

        if closed:
            sleep(0.5)
            break

        temp.append(user[1])  # is_bot

        try:
            fol = api.users.getFollowers(user_id=long_id)  # Получаем информацию о подписчиках пользователя
            temp.append(fol['count'])  # Добавляем количество подписчиков во временное хранилище
        except Exception as e:
            temp.append('')

        sleep(0.5)

        try:
            frn = api.friends.get(user_ids=long_id)  # Получаем информацию о друзьях пользователя
            temp.append(frn['count'])  # Добавляем количество друзей во временное хранилище
        except Exception as e:
            temp.append('')

        sleep(0.5)

        try:
            wll = api.wall.get(owner_id=long_id)  # Получаем информацию о стенах пользователя
            temp.append(wll['count'])  # Добавляем количество записей на стене во временное хранилище
        except Exception as e:
            temp.append('')

        sleep(0.5)

        ph_cnt = 0
        try:
            wll_ph = api.photos.get(owner_id=long_id, album_id='wall')  # Получаем информацию о фотографиях на стене пользователя
            ph_cnt += int(wll_ph['count'])  # Считаем количество фотографий на стене
            sleep(0.5)
            prf_ph = api.photos.get(owner_id=long_id, album_id='profile')  # Получаем информацию о профильных фотографиях пользователя
            ph_cnt += int(prf_ph['count'])  # Считаем количество профильных фотографий
            sleep(0.5)
            svd_ph = api.photos.get(owner_id=long_id, album_id='saved')  # Получаем информацию о сохраненных фотографиях пользователя
            ph_cnt += int(svd_ph['count'])  # Считаем количество сохраненных фотографий
            temp.append(str(ph_cnt))  # Добавляем общее количество фотографий во временное хранилище
        except Exception as e:
            if ph_cnt > 0:
                temp.append(str(ph_cnt))
            else:
                temp.append('')

        sleep(0.5)
        
        try:
            grp = api.groups.get(user_id=long_id)  # Получаем информацию о группах пользователя
            temp.append(grp['count'])  # Добавляем количество групп во временное хранилище
        except Exception as e:
            temp.append('')

        sleep(0.5)

        final.append(temp)  # Добавляем данные пользователя в итоговый результат

    return final  # Возвращаем итоговый результат
