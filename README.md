# СРБД - Робота з `bytea` та `Large Objects` у PostgreSQL

## Налаштування та запуск

Запустимо PostgreSQL:

```sh
docker compose up -d
```

Підключимось до БД `filestream`, у якій вже будуть створені необхідні таблиці, процедури та функції для виконання роботи (див. файл `seed.sql`):

```sh
docker exec -it srbd-postgres psql -U postgres -d filestream
```

## Сценарії використання

Додавання даних:

```sql
DO $$
DECLARE
  file_records RECORD;
BEGIN
  FOR file_records IN
    SELECT * FROM (VALUES
      ('database.txt', 'Database'),
      ('server.txt', 'Server'),
      ('course.txt', 'Course')
    ) AS files(filename, content)
  LOOP
    CALL insert_text_file(file_records.filename, file_records.content);
  END LOOP;
END $$;
```

Читання даних:

```sql
SELECT read_text_file('database.txt') AS content;
```

Оновлення даних:

```sql
CALL update_text_file('database.txt', 'Modified Database');
```

Видалення даних:

```sql
CALL remove_text_file('server.txt');
```
