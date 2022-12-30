import json
import os


class Config:
    def __init__(self):
        base_dir = os.path.dirname(
            os.path.dirname(__file__)).replace('\\', '/')

        with open(f'{base_dir}/app_settings.json') as f:
            configuration = json.load(f)

        self._version = configuration['version']

    @property
    def version(self):
        return self._version
