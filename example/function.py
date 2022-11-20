import os


def handler(_event, _context):
    name = os.getenv("NAME")
    secret = os.getenv("SUPER_SECRET")
    return f'Hello {name}, my secret is: {secret}'
