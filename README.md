[![Build status](https://circleci.com/gh/sgmap/mpal.svg?style=shield&circle-token=50a0754f6e164ff97a3f479374102a568b750847)](https://circleci.com/gh/sgmap/mpal/tree/dev)

# Les aides de l'Anah

Vous reculez devant un projet d'amélioration de votre logement pourtant nécessaire à votre santé et votre confort, car la complexité des démarches vous effraie : vous ne savez pas à qui vous adresser, vous ne savez pas évaluer le coût restant de votre poche, vous ne savez pas combien de temps cela prendra.

Vous êtes accompagné tout au long de votre démarche par des intervenants compétents pour faire aboutir votre projet.

Grâce au service "les aides de l'Anah", votre projet prend forme en quelques minutes chez vous, 24h/24 et 7j/7 par Internet :
- vous êtes orienté vers un interlocuteur compétent et proche de chez vous - dans votre département ;
- vous êtes conseillé dans votre projet selon votre situation et vos besoins ;
- vous recevez une évaluation personnalisée des aides auxquelles vous pouvez prétendre ;
- vous ne fournissez que les justificatifs strictement nécessaires ;
- vous êtes informé en permanence de l'avancement de votre dossier et des délais prévisibles ;

Les aides de l'Anah est le service pour l'amélioration du logement qui réunit tous les acteurs et toutes les compétences au service du projet d'amélioration de votre logement.

# Installation (avec Docker)

```shell
cp config/database.yml{.sample,}
cp .env{.sample,}
docker-compose run mpal db:setup
docker-compose run mpal db:setup RAILS_ENV=test`
docker-compose up

docker-compose run mpal rake intervenants:charger
```

# Installation (sans passer par Docker)

Pré-requis : ce projet nécessite un serveur PostgreSQL et un serveur Redis lancés localement.

## Configurer l'environnement

```shell
# Création des fichiers de configuration
cp .env.sample .env
cp config/database.yml.sample config/database.yml
# Création de l'utilisateur de la base de données
# (mot de passe : `mpal`)
createuser --superuser --createdb mpal
# Création de la base de données
rake db:setup
rake db:seed
```

## Lancer le projet

```shell
foreman start
```

# Notes

Kanban Zenhub sur ce projet

# UX / UI

https://projects.invisionapp.com/share/DK96M9YUB#/screens

# Wiki

https://github.com/sgmap/mpal/wiki

# Api utilisées (Voir dossier `app/services`)

## Api particulier
- https://particulier.api.gouv.fr/tech/#introduction
- https://particulier.api.gouv.fr/docs/

Exemple de requête :

curl "https://particulier-test.api.gouv.fr/api/impots/svair?numeroFiscal=12&referenceAvis=15" \
  -H "X-API-KEY: test-token" \
  -H "accept: application/json" \
  -H "X-User: demo"

## Api ban

- https://adresse.data.gouv.fr/api/
