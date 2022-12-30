from flask_restx import Api
from .default import api as default_api
from services import config

conf = config.Config()

api = Api(title="Test API", description="Test API", version=conf.version)

api.add_namespace(default_api)
