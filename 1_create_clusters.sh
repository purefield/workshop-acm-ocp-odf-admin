. /srv/login.sh
oc-login 1
rm workshop_id_rsa* -f
ssh-keygen -qP '' -C 'workshop-root' -f workshop_id_rsa
export $(cat secrets.env)
export size=1
export infra_nodes=3
export worker_nodes=2
export label='lab: ocp-cns'
for id in $(seq -w 01 $size); do
  name=user$id
  yaml=odf-cluster.$name.yaml
  config=$(perl -pe "s/CLUSTERNAME/$name/g" install-config.yaml.tmpl | 
    perl -pe "s/INFRA_NODES/$infra_nodes/g" |
    perl -pe "s/WORKER_NODES/$worker_nodes/g" |
    perl -pe 's/SSH_PUB_KEY/`cat workshop_id_rsa.pub | perl -pe "s|\n||g"`/e' |
    base64 -w0)
  perl -pe "s/CLUSTERNAME/$name/g" odf-cluster.yaml.tmpl |
    perl -pe "s/LABEL/$label/g" |
    perl -pe "s/WORKER_NODES/$worker_nodes/g" |
    perl -pe "s/INFRA_NODES/$infra_nodes/g" |
    perl -pe 's/AWS_ACCESS_KEY_ID/`echo -n \$AWS_ACCESS_KEY_ID`/e' |
    perl -pe 's/AWS_SECRET_ACCESS_KEY/`echo -n \$AWS_SECRET_ACCESS_KEY`/e' |
    perl -pe 's/BASE_DOMAIN/`echo -n \$BASE_DOMAIN`/e' |
    perl -pe 's/SSH_PRIVATE_KEY.$/`cat workshop_id_rsa | perl -pe "s|^|    |g"`/se' |
    perl -pe 's/DOCKER_CONFIG_JSON.$/`cat dockerconfig.json`/se' |
    perl -pe "s/(\s+install-config.yaml\:\s*).*$/\$1$config/" > $yaml
    oc apply -f $yaml
done
