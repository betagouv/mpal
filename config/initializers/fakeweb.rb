FakeWeb.register_uri(
:get, "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=12&referenceAvis=15",
content_type: 'application/json',
body: JSON.generate({
  "declarant1": {
    "nom": "Martin",
    "prenoms": "Pierre",
    "dateNaissance": "19/03/1980"
  },
  "anneeImpots": "2015",
  "nombrePersonnesCharge": 2,
  "foyerFiscal": {
    "adresse": "12 rue de la mare, 75010 Paris"
  },
  "revenuFiscalReference": 29880
}),
)

FakeWeb.register_uri(
:get, "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=95&referenceAvis=1595",
content_type: 'application/json',
body: JSON.generate({
  "declarant1": {
    "nom": "Rafu",
    "prenoms": "Caroline",
    "dateNaissance": "06/05/1979"
  },
  "anneeImpots": "2015",
  "nombrePersonnesCharge": 1,
  "nombreParts": 2,
  "foyerFiscal": {
    "adresse": "27 rue des Ecoles, 95610 Eragny"
  },
  "revenuFiscalReference": 10250
}),
)

FakeWeb.register_uri(
:get,  "http://#{ENV['API_BAN_DOMAIN']}/search/?q=27 rue des Ecoles, 95610 Eragny",
content_type: 'application/json',
body: JSON.generate({
  "features": [
    {
      "properties": {
        "label": "27 rue des Ecoles, 95610 Eragny",
        "postcode": "95610",
        "citycode": "95610",
        "name": "27 rue des Ecoles",
        "city": "Eragny"
      },
      "geometry": {
        "coordinates": {
          "latitude": "47",
          "longitude": "4"
        }
      }
    }
  ]
})
)

FakeWeb.register_uri(
:get,  "http://#{ENV['API_BAN_DOMAIN']}/search/?q=12 rue de la Mare, 75010 Paris",
content_type: 'application/json',
body: JSON.generate({
  "features": [
    {
      "properties": {
        "label": "12 rue de la Mare, 75010 Paris",
        "postcode": "75010",
        "citycode": "75010",
        "name": "12 rue de la Mare",
        "city": "Paris"
      },
      "geometry": {
        "coordinates": {
          "latitude": "58",
          "longitude": "6"
        }
      }
    }
  ]
})
)

FakeWeb.register_uri(
:post,  %r|#{ENV['OPAL_API_BASE_URI']}/createDossier|,
content_type: 'application/json',
body: JSON.generate({
  "dosNumero": "09500840",
  "dosId": 959496
}),
status: [201, "Created"]
)
