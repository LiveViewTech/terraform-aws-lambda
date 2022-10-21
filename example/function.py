import os


def handler(_event, _context):
    name = os.getenv("NAME")
    secret = os.getenv("SUPER_SECRET")
    print(f'Hello {name}, my secret is: {secret}')


if __name__ == "__main__":
    handler(None, None)
