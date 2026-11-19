# Comparatif credesbois 0.0.1 / Aria 3.0.0 / suprminer 1.9.47

Mesures du 19/11/2026. Le critere est le rendement **mesure cote pool** : le travail que le pool credite au worker.
Les MH/s affiches ne se comparent pas d un mineur a l autre, car chacun compte a sa facon.

## Resultats

| Carte | OC (identique pour les 3) | Mineur | Frais | Affiche (Kepler / TESS / moyenne) | Mesure cote pool |
|---|---|---|---|---|---|
| RTX 5070 Ti | HiveOS, limite 250 W, memoire 14301 MHz, coeur en boost auto | credesbois 0.0.1 | 1 % | 117 / 127 / 123 MH/s | ~148 MH/s (moteur mesure a 149.8 MH/s +-10 %, moins 1 % de frais) |
| RTX 5070 Ti | idem | Aria 3.0.0 | 1 % | -- / -- / 104.5 MH/s | 119.6 MH/s +-10 % |
| RTX 5070 Ti | idem | suprminer 1.9.47 | 0 % | 67 / 71 / 68.7 MH/s | 67.8 MH/s +-0.7 % |

Sur RTX 5070 Ti, credesbois rapporte environ **+25 % par rapport a Aria 3.0.0** et environ **2.2x suprminer 1.9.47**
(rendement cote pool, frais compris).

Les mesures sur RTX 3060 Ti, 3070, 4070 Ti Super, 4080 et 5060 Ti sont **a venir**, avec la meme methode. Aucun chiffre
n est donne pour ces cartes tant qu il n a pas ete mesure.

## Methode

- Meme machine, meme carte, meme OC, pas d autre mineur en meme temps. Chaque mineur utilise un worker neuf et tourne
  de 10 a 30 min.
- **AriaPool** (Aria et credesbois/nebminer) : le travail credite est lu dans l API du pool
  (`/neb-api/wallet/<adresse>/workers`, champ `work_24h` du worker neuf), puis divise par la duree de connexion.
  L incertitude est d environ 1/sqrt(nombre de parts), soit +-10 % pour environ 100 parts.
- **suprnova** (suprminer) : nombre de parts acceptees par le pool x difficulte de part, divise par la duree. La mesure
  s est faite sur le port a difficulte fixe 2M : 20 337 parts, d ou l incertitude de +-0.7 %.
- Le hashrate affiche par l API de suprnova n est pas utilise : il sous-estime d environ 25 % le travail que le pool a
  lui-meme accepte, pour tous les mineurs.
- La colonne Kepler / TESS donne les vitesses affichees par slot (blocs pairs = Kepler, impairs = TESS). Aria
  n indique pas le slot dans son journal.

---

# Comparison (English)

Pool-side measured yield, on the same card with the same overclock (RTX 5070 Ti, HiveOS, 250 W limit):

- credesbois 0.0.1: about 148 MH/s, including the 1 % fee;
- Aria 3.0.0: 119.6 MH/s +-10 %;
- suprminer 1.9.47: 67.8 MH/s +-0.7 %.

The other cards will be added once measured. The method is described above, in French.
