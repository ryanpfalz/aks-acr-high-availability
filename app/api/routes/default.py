from services import utils
from flask_restx import Resource, Namespace

api = Namespace("default", description="Default operations")


@api.route('/')
class Default(Resource):
    @staticmethod
    # @cross_origin(headers=["Content-Type", "Authorization"])
    def get():
        return utils.http_response('Hello world', 200)
