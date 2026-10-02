# Sama Wallet — lancement et déploiement

Le backend Spring Boot est dans `Projet_wallet-main/` et l'application Flutter dans `wallet_mobile/`.

## Voir la démo sur cet ordinateur

Lancer `bash scripts/start-demo.sh`, puis ouvrir **http://localhost:8080**. Ce serveur local sert le front et relaie `/wallet/` vers le port 8091 et `/services/` vers le port 8092. Si vous lancez Flutter avec `flutter run -d chrome` sur un autre port, ce relais n'existe pas : la page s'affiche mais la connexion échoue. Dans ce cas, utiliser l'URL 8080 ou renseigner les deux adresses API dans les paramètres du formulaire.

Le compte créé lors de la validation initiale est **+221778080432**, PIN **1234**, si les volumes PostgreSQL locaux n'ont pas été supprimés. Les montants sont fictifs.

Pour créer un nouveau compte : demander un OTP, lire le code affiché dans les logs du portefeuille, vérifier l'OTP puis choisir un PIN. Aucun SMS réel n'est envoyé.

## Render

La configuration [render.yaml](render.yaml) décrit :

- une base Render PostgreSQL gratuite partagée par les deux applications Java (leurs noms de tables ne se chevauchent pas) ;
- `sama-wallet-api` et `sama-prestations-api`, deux services web Docker gratuits ;
- `sama-wallet-mobile`, un site statique gratuit contenant le build Flutter ;
- `sama-wallet-kafka`, un service privé **payant** avec un disque persistant **payant**, pour conserver le paiement asynchrone testé.

Il faut un compte Render connecté à un dépôt Git contenant **la racine entière de ce projet**. Pour publier une modification Flutter, exécuter `bash scripts/prepare-render-web.sh` avant le commit ; cette commande actualise les fichiers statiques versionnés dans `deploy/render-web/`. Les fichiers Java sont compilés directement par leurs Dockerfiles lors du déploiement.

Dans Render : **New → Blueprint**, choisir le dépôt et sa branche, laisser `render.yaml` à la racine, examiner le prix affiché pour Kafka et le disque, puis confirmer la création. Attendre que la base, le broker, les deux API et le site soient opérationnels. L'URL du site `sama-wallet-mobile` sera l'adresse publique à présenter. Les URL des API et l'origine CORS sont reliées entre services par les variables du Blueprint. Le secret JWT est généré par Render et partagé entre les deux API.

Pour vérifier : ouvrir le site, créer un compte avec un numéro de démonstration, récupérer l'OTP dans les **logs de `sama-wallet-api`**, faire un dépôt fictif, créer puis payer une prestation, vérifier que son statut devient « Payée ». Le compte local `+221778080432` n'existe pas dans la nouvelle base Render tant qu'il n'y est pas recréé.

**Limites de l'offre gratuite Render :** un seul PostgreSQL gratuit par espace, expiration de cette base après 30 jours, mise en veille des services web gratuits après 15 minutes sans trafic et réveil pouvant prendre environ une minute. Deux API gratuites consomment les heures gratuites de l'espace. Kafka privé et son disque restent payants. Au tarif affiché lors de la préparation : **7 $/mois** pour le petit service privé et **0,25 $/Go/mois** pour le disque, facturés au prorata ; contrôler le total dans Render avant de valider. Voir la [documentation Render](https://render.com/docs/free).

Le projet conserve la logique Kafka. Toute alternative sans Kafka changerait la confirmation de paiement et doit être décidée explicitement pour cet exercice.

## Vérifications

Le test `python3 scripts/smoke_test.py` a validé 36 appels HTTP lors du dernier passage complet : OTP, connexion, solde, dépôt/retrait, refus d'erreurs, prestation, paiement confirmé par Kafka, ressources et tâches. Les deux Maven produisent leurs JAR. `flutter analyze`, `flutter test` et `flutter build web --release` passent. L'interface a été vérifiée à la largeur d'un téléphone.

Le SDK Android est absent de cette machine : aucun APK n'a été produit. Le projet Flutter Android existe dans `wallet_mobile/android`. La présentation immédiate peut utiliser le site Flutter web sur un téléphone dès que Render est opérationnel.
