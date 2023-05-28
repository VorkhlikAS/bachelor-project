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
    """Retrieve VK API data for a given user ID and fields"""
    fields = get_params("fields")
    try:
        result = api.users.get(user_ids=user_id, fields=fields[0])
        sleep(0.5)
        return result
    except vk.exceptions.VkAPIError as e:
        print(f"VK API error occurred: {e}")
        return None

 
def get_users_by_file(filename: str, test: int = 0):
    token, version = get_params("token", "version")
    api = get_api(token=token, version=version)
    data = get_data(filename)
    api_result = []

    for user in data:
        if test != 1:
            api_result.append([get_user_data(user[0], api), user[1]])
        else:
            api_result.append([get_user_data(user[0], api), ''])

    final = []

    for user in api_result:
        temp = []
        print(f'DEBUG: items: {user[0][0].items()}')
        print(f'DEBUG: isbot = {user[1]}')
        long_id = user[0][0]['id']
        print(f'DEBUG: long id = {long_id}')
        closed = False
        for i, col in enumerate(ALL_COLS):
            if col in user[0][0]:
                if test != 1 and col == 'is_closed' and user[0][0][col] == 'True':
                    closed = True
                    break
                print(i, col, user[0][0][col])
                temp.append(str(user[0][0][col]))
            else:
                print(f'{i} Missing: {col}')
                temp.append('')

        if closed:
            sleep(0.5)
            break

        temp.append(user[1])  # is_bot

        try:
            fol = api.users.getFollowers(user_id=long_id)
            temp.append(fol['count'])
        except Exception as e:
            temp.append('')
        sleep(0.5)

        try:
            frn = api.friends.get(user_ids=long_id)
            temp.append(frn['count'])
        except Exception as e:
            temp.append('')
        sleep(0.5)

        try:
            wll = api.wall.get(owner_id=long_id)
            temp.append(wll['count'])
        except Exception as e:
            temp.append('')
        sleep(0.5)

        ph_cnt = 0
        try:
            wll_ph = api.photos.get(owner_id=long_id, album_id='wall')
            ph_cnt += int(wll_ph['count'])
            sleep(0.5)
            prf_ph = api.photos.get(owner_id=long_id, album_id='profile')
            ph_cnt += int(prf_ph['count'])
            sleep(0.5)
            svd_ph = api.photos.get(owner_id=long_id, album_id='saved')
            ph_cnt += int(svd_ph['count'])
            temp.append(str(ph_cnt))
        except Exception as e:
            if ph_cnt > 0:
                temp.append(str(ph_cnt))
            else:
                temp.append('')
        sleep(0.5)
        
        try:
            grp = api.groups.get(user_id=long_id)
            temp.append(grp['count'])
        except Exception as e:
            temp.append('')
        sleep(0.5)

        final.append(temp)

    return final


# if __name__ == '__main__':
#     token, version = get_params("token", "version")
#     api = get_api(token=token, version=version)
#     fields = get_params("fields")


#     a = api.users.getFollowers(user_id='350924606')
#     print(a['count'])
#     print('=======================FOL=========================')
#     a = api.friends.get(user_ids='danilmakarkin')
#     print(a['count'])
#     print('=======================FRN=========================')
#     a = api.wall.get(owner_id='350924606')
#     print(a['count'])
#     print('=======================WLL=========================')
#     try:
#         a = api.photos.get(owner_id='350924606', album_id='wall')
#         print(a['count'])
#         a = api.photos.get(owner_id='350924606', album_id='profile')
#         print(a['count'])
#         a = api.photos.get(owner_id='350924606', album_id='saved')
#         print(a['count'])
#     except Exception as e:
#         print(e)
#     print('=======================PHT=========================')
#     a = api.groups.get(user_id='350924606')
#     print(a['count'])
#     print('=======================GRP=========================')
