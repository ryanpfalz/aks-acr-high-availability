from flask import jsonify, make_response


def http_response(message, status_code):
    return make_response(jsonify(message), status_code)
