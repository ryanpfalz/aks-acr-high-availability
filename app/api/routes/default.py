from services import utils
from flask_restx import Resource, Namespace

import socket
import requests

api = Namespace("default", description="Default operations")


@api.route('/')
class Default(Resource):
    @staticmethod
    def get():
        # for demo, return host name and Public IP
        hostname = socket.gethostname()

        resp = requests.get('https://ipinfo.io/json', verify=True)
        if resp.status_code != 200:
            ip_addr = 'Error'
        else:
            ip_addr = resp.json()['ip']

        return utils.http_response(
            {
                'hostname': hostname,
                'ip': ip_addr
            },
            200
        )
