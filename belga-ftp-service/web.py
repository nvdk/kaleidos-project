import flask
import os
import helpers
import builtins
from escape_helpers import sparql_escape
from rdflib.namespace import Namespace
from .belgaftp import BelgaFTPService

app = flask.Flask(__name__)
BELGA_USER = os.environ['BELGA_USER']  # TODO fix on server
BELGA_PWD = os.environ['BELGA_PWD']  # TODO fix on server

belga_service = BelgaFTPService()


@app.route("/", methods=['GET'])
def home():
    return "Belga FTP service is up and running"


def push_to_belga():
    xmlfile = belga_service.build_xml()


@app.route("/agenda/publish", methods=['POST'])
def publish():
    req = flask.request.json
    agenda = req['agenda']
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
        PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
        PREFIX prov: <http://www.w3.org/ns/prov#>
        
        SELECT *
        WHERE {{
          GRAPH <http://mu.semte.ch/application> {{
            ?agenda a besluitvorming:Agenda .
            ?agenda dct:hasPart ?item .
            ?kortbestek prov:generated ?item .
            OPTIONAL{{
              ?kortbestek dct:title ?title .
            }}
            OPTIONAL{{
              ?kortbestek dbpedia:subtitle ?subtitle .
            }}
            OPTIONAL{{
              ?kortbestek besluitvorming:inhoud ?text .
            }}
            OPTIONAL{{
              ?kortbestek dct:issued ?date .
            }}
            OPTIONAL{{
              ?kortbestek ext:issuedDocDate ?docdate .
            }}
            FILTER(?agenda = <{agenda}>)
          }}
        }}
    """
    results = helpers.query(q)
    items = list()
    try:
        for file in results['results']['bindings']:
            f_dict = dict()
            for key, obj in file.items():
                f_dict[key] = obj['value']
            items.append(f_dict)
    except:
        print("Could not parse results")
    text = ""
    for i in items:
        text += f"""{i['subtitle']}\n{i['text']}\n"""
    agendaparts = str(agenda).split('/')
    unique_id = agendaparts[len(agendaparts)-1]
    print(unique_id)
    xmlfile = belga_service.build_xml(pub_id=unique_id, title="Persagenda Vlaamse Overheid", subtitle="",
                                      press_message=text, write_to_file=False)
    belga_service.upload_file(unique_id, BELGA_USER, BELGA_PWD, xmlfile)
    return flask.jsonify(text)


@app.route("/dir", methods=["GET"])
def get_ftp_files():
    files = belga_service.get_repository(BELGA_USER, BELGA_PWD)
    return files


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
