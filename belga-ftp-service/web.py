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


@app.route("/agenda/publish", methods=['POST'])
def publish():
    req = flask.request.json
    agenda = req['agenda']
    q = f"""
        PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
        PREFIX dct: <http://purl.org/dc/terms/>
        PREFIX prov: <http://www.w3.org/ns/prov#>
        PREFIX dbpedia: <http://dbpedia.org/ontology/>
        PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
        
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
    debug = True if (os.environ.get('MODE') == "development") else False
    app.run(debug=debug, host='0.0.0.0')
