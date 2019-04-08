import requests

end_of_pages = False
page = 1
parsed_results = list()
query = "inmeta:publicatiedatum:daterange:2019-03-14..&requiredfields=aggregaat:voorstel%20of%20ontwerp%20van%20decreet.paginatype:Parlementair%20document"  # zittingsjaar%3D2018-2019


while True:
    req = requests.get(f"http://ws.vlpar.be/api/swagger/api/search/query/{query}?page={page}&max=25"
                       f"&collection=vp_collection&sort=date")
    response = req.json()

    if 'result' in response:
        results = response['result']
        for result in results:
            parsed = dict()
            parsed['title'] = result['title']
            parsed['doc_url'] = result['url']
            for pair in result['metatags']['metatag']:
                parsed[pair['name']] = pair['value']
            if 'indiener' in parsed and parsed['indiener'].lower() != "de vlaamse regering":
                parsed_results.append(parsed)
        if len(parsed_results) >= int(response['count']):
            break
        else:
            page += 1
    else:
        print(response)
        break
print("done")
