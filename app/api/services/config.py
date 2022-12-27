import json
import os


class Config:
    def __init__(self):
        base_dir = os.path.dirname(
            os.path.dirname(__file__)).replace('\\', '/')

        with open(f'{base_dir}/app_settings.json') as f:
            configuration = json.load(f)

        # self._var = configuration['key']

    # @property
    # def property_name(self):
    #     return self._var
