// VIRTUOSO bug: https://github.com/openlink/virtuoso-opensource/issues/515
import mu from 'mu';
import { ok } from 'assert';
import cors from 'cors';

const app = mu.app;
const moment = require('moment');
const bodyParser = require('body-parser');

app.use(cors())
app.use(bodyParser.json({ type: 'application/*+json' }))

app.post('/approveAgenda', async (req, res) => {
	const newAgendaId = req.body.newAgendaId;
	const oldAgendaId = req.body.oldAgendaId;
	const currentSessionDate = req.body.currentSessionDate;

	const newAgendaURI = await getNewAgendaURI(newAgendaId);
	const agendaData = await copyAgendaItems(oldAgendaId, newAgendaURI);
	// const data = await getDocumentsURISFromAgenda(newAgendaId);

	// const vars = data.head.vars;
	// const documentVersionsToChange = createDocumentVersionObjects(data, vars);
	// const resultsAfterUpdates = await updateSerialNumbersOfDocumentVersions(documentVersionsToChange, currentSessionDate);

	res.send({ status: ok, statusCode: 200, body: { agendaData: agendaData } }); // resultsOfSerialNumbers: resultsAfterUpdates
});

async function getNewAgendaURI(newAgendaId) {
	const query = `
 	PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
 	PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
 	PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>

 	SELECT ?agenda WHERE {
  	GRAPH <http://mu.semte.ch/application> {
   		?agenda a besluitvorming:Agenda ;
   		mu:uuid "${newAgendaId}" .
  	}
 	}
 `

	const data = await mu.query(query).catch(err => { console.error(err) });
	return data.results.bindings[0].agenda.value;
}

async function copyAgendaItems(oldId, newUri) {
	// SUBQUERY: Is needed to make sure the uuid isn't generated for every variable.
	const query = `
	PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
	PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
	PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
  PREFIX dct: <http://purl.org/dc/terms/>

	INSERT { 
		GRAPH <http://mu.semte.ch/application> {
    	<${newUri}> dct:hasPart ?newURI .
    	?newURI ?p ?o .
    	?s ?p2 ?newURI .
    	?newURI mu:uuid ?newUuid
		}
	} WHERE { { SELECT * WHERE {
    GRAPH <http://mu.semte.ch/application> {
  		?agenda a besluitvorming:Agenda ;
			mu:uuid "${oldId}" .
			?agenda dct:hasPart ?agendaitem .

			OPTIONAL { ?agendaitem mu:uuid ?olduuid } 
			BIND(IF(BOUND(?olduuid), STRUUID(), STRUUID()) as ?uuid)
			BIND(IRI(CONCAT("http://localhost/vo/agendaitems/", ?uuid)) AS ?newURI)

			OPTIONAL { 
				SELECT ?agendaitem ?p ?o
				WHERE {
					?agendaitem ?p ?o .
					FILTER(?p != mu:uuid)
				}
			}
			OPTIONAL { 
				SELECT ?agendaitem ?s ?p2 
				WHERE {
					?s ?p2 ?agendaitem .
					FILTER(?p2 != dct:hasPart)
				}
			}    
		} } }
		BIND(STRAFTER(STR(?newURI), "http://localhost/vo/agendaitems/") AS ?newUuid) 
	}
`

	return await mu.update(query).catch(err => { console.error(err) });
}

async function getDocumentsURISFromAgenda(agendaId) {
	const query = `
	PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
	PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
	PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
  PREFIX dct: <http://purl.org/dc/terms/>
	
	SELECT ?documentURI ?documentName ?versionNumber ?idNr ?creationDate ?serialNumber
		WHERE {
			GRAPH <http://mu.semte.ch/application> {
				?agenda a 	 besluitvorming:Agenda ;
										 mu:uuid "${agendaId}" ;
										 dct:hasPart ?agendaitems .
				?subcase besluitvorming:isGeagendeerdVia ?agendaitems ;
				         ext:bevatDocumentversie ?documentURI ; 
				?documentURI 	 ext:gekozenDocumentNaam  ?documentName ;
                       ext:versieNummer         ?versionNumber ;
                       ext:idNumber             ?idNr ;
											 dct:created              ?creationDate .
			OPTIONAL { ?documentURI ext:serieNummer  ?serialNumber . }
		}        
	}
	`
	return await mu.query(query).catch(err => { console.error(err) });
}

function createDocumentVersionObjects(data, vars) {
	const bindings = data.results.bindings;
	let documentVersions = [];
	for (let index = 0; index < bindings.length; index++) {
		if(!bindings[index].serialNumber) {
			let documentVersionObject = {};
			vars.forEach(varKey => {
				if(varKey != 'serialNumber') {
					documentVersionObject[varKey] = bindings[index][varKey].value;
				}
			});
			documentVersions.push(documentVersionObject);
		}
	}
	return documentVersions;
}

async function updateSerialNumbersOfDocumentVersions(documents, currentSessionDate) {
	let insertString = "";

	documents.forEach(document => {
		const numberToAssignToDocument = createIdNumberOfCertainLength(document.idNr);
		// TODO: BIS/TRES/... 
		insertString = `${insertString}
    	<${document.documentURI}> ext:serieNummer "VR${moment(currentSessionDate).format('YYYYMMDD')}_${numberToAssignToDocument}_BIS" .
    `
	})
	if(!insertString.includes('ext:serieNummer')) {
		console.error('InsertString is not defined. We cannot insert items.')
		return undefined;
	}
	const queryString = `
		PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
		PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
		PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>

		INSERT DATA { 
			GRAPH <http://mu.semte.ch/application> { 
				${insertString}
			}
		}
	`
	
	return await mu.update(queryString).catch(err => { console.error(err) });
}

function createIdNumberOfCertainLength(numberToEdit, length = 4) {
	const numberLength = numberToEdit.toString().length;
	const lengthDiff = length - numberLength;

	let zeroStringToAdd = "";
	for (let index = 0; index < lengthDiff; index++) {
		zeroStringToAdd += "0";
	}

	return zeroStringToAdd + numberToEdit;
}

mu.app.use(mu.errorHandler);