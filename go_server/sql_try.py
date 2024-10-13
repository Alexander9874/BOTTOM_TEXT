
import psycopg2
from psycopg2 import Error

try:
    # Подключиться к существующей базе данных
    connection = psycopg2.connect(user="alexander",
                                  # пароль, который указали при установке PostgreSQL
                                  password="Meow_2022",
                                  host="localhost",
                                  port="5432",
                                  database="bottom_text")

    connection.autocommit = True
    cursor = connection.cursor()
   
#    postgreSQL_select_Query = "SELECT create_user('existing_user_1', 'password');"


    cursor.callproc('create_user',['new_user_1', 'my_secure_password',])
    result = cursor.fetchall()
    print(result)

    cursor.callproc('create_user',['new_user_1', 'my_secure_password',])
    result = cursor.fetchall()
    print(result)

except (Exception, Error) as error:
    print("Ошибка при работе с PostgreSQL", error)
finally:
    if connection:
        cursor.close()
        connection.close()
        print("Соединение с PostgreSQL закрыто")