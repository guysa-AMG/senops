import requests


def fetch_untrusted(url):
    return requests.get(url)


user_input = input("Enter URL: ")
response = fetch_untrusted(user_input)
print(response.status_code)
