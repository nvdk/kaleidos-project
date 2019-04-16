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


def get_files(phase):
    files = list()
    q = f"""
            PREFIX core: <http://mu.semte.ch/vocabularies/core/>
            PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
            PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
            PREFIX dct: <http://purl.org/dc/terms/>
            PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
            PREFIX adms: <http://www.w3.org/ns/adms#>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            PREFIX dbpedia: <http://dbpedia.org/ontology/>
            PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
            PREFIX nfo: <http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#>

            SELECT *
            WHERE {{
                GRAPH <http://mu.semte.ch/application> {{
                    ?subcase a dbpedia:UnitOfWork .
                    ?subcase ext:subcaseProcedurestapFase ?phase .
                    ?subcase ext:bevatDocumentversie ?docVersie .
                    ?docVersie ext:file ?file .
                    ?phase ext:procedurestapFaseCode ?code .
                    ?code skos:prefLabel ?label .
                    FILTER(?phase = <{phase}>)
                }}
            }}
        """
    response = helpers.query(q)
    try:
        for file in response['results']['bindings']:
            f_dict = dict()
            for key, obj in file.items():
                f_dict[key] = obj['value']
            files.append(f_dict)
    except:
        print("Could not parse results")
    return files


@app.route("/parlement/push", methods=['POST'])
def push_to_parliament():
    req = flask.request.json
    procedurestapfase = req['procedurestapfase']

    return flask.jsonify(get_files(procedurestapfase))


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
    try:
        exec("from ext.app.%s import *" % app_file)
    except Exception as e:
        helpers.log(str(e))
    debug = True if (os.environ.get('MODE') == "development") else False
    app.run(debug=debug, host='0.0.0.0')
