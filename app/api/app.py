import sys
import os
from flask import Flask
from werkzeug.middleware.proxy_fix import ProxyFix

# allow import from services from any dir
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)).replace('\\', '/') + '/services')

from services import utils
from routes import api

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app)
api.init_app(app)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)  # for docker
    # app.run(host='127.0.0.1', port=8080, use_reloader=False, debug=True)  # for dev
