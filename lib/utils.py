import yaml


def get_config(config_filepath):
    with open(config_filepath, 'r') as f:
        return yaml.load(f)


def inf(msg):
    print(msg)


def err(msg):
    print(msg)


def warn(msg):
    print(msg)
