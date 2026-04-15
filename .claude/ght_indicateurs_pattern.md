TYPE:
rate A/B
flow nb/t
delay t2-t1
dur sum(t)/n
occ used/cap

TRANSFORM:
entropy diversité
concentration inégalité
variance dispersion
distance séquence/parcours
network flux/graph
control écart norme

DIM:
activité
qualité
parcours
efficience
réadmissions
organisation
territoire
financement

LVL:
rsa
ghm
cmd
um
finess
temps

RULE:
- 1 type + 1 dim + 1 lvl (+ transform optionnel)
- données PMSI ou SNDS uniquement
- comparables dans le temps ou entre structures
- transform doit être calculable