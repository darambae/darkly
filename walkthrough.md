# Pages et failles repérées

## Vulnérabilité 1 — Note privée de wil accessible (flag 1)

| URL | Flag | Parcours | En quoi c'est une faille de sécurité |
|---|---|---|---|
| `http://localhost:4942/profile/k1asdfeditojrb4` | `FLAG{1d0r_ur_pr0f1l3_1s_m1n3}` | Ouvrir une conversation, puis cliquer sur le pseudo de `wil`. | La note privée de wil est visible depuis une session qui n'est pas la sienne (visiteur sur la capture, puis jdoe dans le HTML fourni). Le site divulgue une information réservée au propriétaire du profil. |

## Vulnérabilité 2 — Réinitialisation du mot de passe sans vérification

| URL | Flag | Parcours | En quoi c'est une faille de sécurité |
|---|---|---|---|
| Page « Mot de passe oublié » (URL à relever) | Aucun flag signalé | Relever l'adresse mail de `wil` sur son profil, aller sur « Sign in », puis sur « Mot de passe oublié » et saisir cette adresse. Le mot de passe peut être changé immédiatement, sans utiliser le lien envoyé par mail. | La seule connaissance de l'adresse mail suffit à modifier le mot de passe : la possession de la boîte mail n'est pas vérifiée. Cela permet de prendre le contrôle du compte de `wil`. |

## Vulnérabilité 3 — Exposition de données par l'API des notes (flag 2)

| URL | Flag | Parcours | En quoi c'est une faille de sécurité |
|---|---|---|---|
| `http://localhost:4942/api/grades` | `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}` | Repérer `/api/grades` dans `robots.txt`, puis lire la réponse JSON. Le flag apparaît dans l'entrée du projet `Darkly`, dont le score est `0`. | L'API renvoie un flag dans les données d'une note malgré ce score. Cette observation ne suffit pas à établir que les notes d'autres étudiants sont accessibles. |
