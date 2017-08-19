from lib import settings as s


# Initialize objects
app = {
    'envs': [],
    'provisioners': [],
    'providers': {
        'aws': {},
        'ovh': {},
        'google': {}
    }
}
