import flask
import os
import helpers
import builtins
from escape_helpers import sparql_escape
from rdflib.namespace import Namespace

app = flask.Flask(__name__)


@app.route("/", methods=['GET'])
def home():
    return "API Vlaams Parlement service is up and running"


@app.route("/domain/transfer", methods=['POST'])
def transfer_domain():
    req = flask.request.json
    receiving_mandatee = req['receiving_mandatee']
    q = f"""
        
    """
    return flask.jsonify(helpers.query(q))


"""
Vocabularies
"""
mu = Namespace('http://mu.semte.ch/vocabularies/')
mu_core = Namespace('http://mu.semte.ch/vocabularies/core/')
mu_ext = Namespace('http://mu.semte.ch/vocabularies/ext/')

graph = os.environ.get('MU_APPLICATION_GRAPH')
SERVICE_RESOURCE_BASE = 'http://mu.semte.ch/services/'

"""
Start Application
"""
if __name__ == '__main__':
    builtins.app = app
    builtins.helpers = helpers
    builtins.sparql_escape = sparql_escape
    app_file = os.environ.get('APP_ENTRYPOINT')
    f = open('/app/__init__.py', 'w+')
    f.close()
    try:
        exec("from ext.app.%s import *" % app_file)
    except Exception as e:
        helpers.log(str(e))
    debug = True if (os.environ.get('MODE') == "development") else False
    app.run(debug=debug, host='0.0.0.0')
