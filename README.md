# Распознавание ботов в ВК

Проект для распознавания ботов в социальной сети ВКонтакте.

# Установка

1. Клонируйте репозиторий на свой компьютер:
2. Перейдите в директорию проекта
3. Создайте файл settings.yaml со следующей структурой:

```yaml
---
dbname: "postgres"
user: "bot_user"
password: "bot_detector"
host: "db"
token: "<Токен VKApi>"
version: "<Версия>"
fields:
  - 'activities'
  - "about"
  - "blacklisted"
  - "blacklisted_by_me"
  - "books"
  - "bdate"
  - "can_be_invited_group"
  - "can_post"
  - "can_see_all_posts"
  - "can_see_audio"
  - "can_send_friend_request"
  - "can_write_private_message"
  - "career"
  - "common_count"
  - "connections"
  - "contacts"
  - "city"
  - "country"
  - "crop_photo"
  - "domain"
  - "education"
  - "exports"
  - "followers_count"
  - "friend_status"
  - "has_photo"
  - "has_mobile"
  - "home_town"
  - "photo_100"
  - "photo_200"
  - "photo_200_orig"
  - "photo_400_orig"
  - "photo_50"
  - "sex"
  - "site"
  - "schools"
  - "screen_name"
  - "status"
  - "verified"
  - "games"
  - "interests"
  - "is_favorite"
  - "is_friend"
  - "is_hidden_from_feed"
  - "last_seen"
  - "maiden_name"
  - "military"
  - "movies"
  - "music"
  - "nickname"
  - "occupation"
  - "online"
  - "personal"
  - "photo_id"
  - "photo_max"
  - "photo_max_orig"
  - "quotes"
  - "relation"
  - "relatives"
  - "timezone"
  - "tv"
  - "universities"

```

# Использование
Проект предоставляет возможность проверить, является ли заданный профиль ВКонтакте ботом или нет. Для этого необходимо загрузить CSV-файл в следующем формате:

```
<id пользователя>, <Принадлежность к ботам [0, 1]>
```

Для запуска проекта перейдите в корневую папку и запустите проект командой ниже:

```bash
docker-compose up --build
```

Запустить приложение можно в браузере по ссылке localhost:5000.

# Вклад

Если вы хотите принять участие в развитии проекта или помочь его улучшению, вы можете сделать следующее:

- Открыть issue с описанием проблемы или предложения
- Создать pull request с внесением изменений
- Указать ошибки и проблемы в документации или функциональности

Мы будем рады вашему вкладу!

# Лицензия

Проект распространяется под лицензией MIT.

# Авторы

- Ворхлик Александр - @VorkhlikAS

# Связь

Если у вас возникли вопросы, предложения или вы хотите связаться со мной, вы можете связаться через нашу страницу в VK.
