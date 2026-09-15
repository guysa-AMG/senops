import sqlite3


def lookup_user(username):
    conn = sqlite3.connect('example.db')
    cursor = conn.cursor()
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    return cursor.execute(query).fetchall()


print(lookup_user(input("Username: ")))
