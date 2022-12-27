from flask_restx import Api
from .default import api as default_api

api = Api(title="Test API", description="Test API")

api.add_namespace(default_api)
