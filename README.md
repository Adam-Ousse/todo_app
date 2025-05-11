# todo_app

Projet Flutter collaboratif pour la matière : **Développements mobiles multi plateformes**

## Membres de l'équipe

- Adam Gassem
- Malek Belkahla

## Vidéo Démo

<video src="https://www.youtube.com/embed/BlCOnqd9FSk" title="Démo Todo App" width="640" height="360" frameborder="0" allowfullscreen></video>

> Si la vidéo ne s'affiche pas, [regardez-la sur YouTube](https://www.youtube.com/watch?v=BlCOnqd9FSk).

## Description du projet

Cette application est une liste de tâches (To-Do List) développée avec Flutter dans le cadre d'un projet de groupe.  
Elle permet à chaque utilisateur de créer un compte, de se connecter, d'ajouter, modifier, supprimer et trier ses propres tâches.

### Fonctionnalités principales

- **Authentification** simple par nom d'utilisateur et mot de passe (stockés dans Firebase)
- **Gestion des tâches** : ajout, édition, suppression, marquage comme terminée
- **Filtrage** des tâches par date (aujourd'hui, demain, 7 jours)
- **Tri** par date ou priorité
- **Gestion des états** avec `StatefulWidget` et `setState`
- **Stockage cloud** avec Firebase Firestore (chaque tâche est liée à un utilisateur)
- **Persistance de la session** grâce à `shared_preferences`
- **Déconnexion** possible depuis le menu latéral

### Technologies et packages Flutter utilisés

- **Flutter** (UI multi-plateforme)
- **cloud_firestore** : stockage et synchronisation des tâches et utilisateurs
- **firebase_core** : initialisation de Firebase
- **shared_preferences** : gestion de la session utilisateur locale
- **Material Design** : interface utilisateur moderne et réactive
