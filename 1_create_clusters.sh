. /srv/login.sh
oc-login 1
for id in $(seq -w 01 2); do
  name=user$id
  yaml=odf-cluster.$name.yaml
  config=$(perl -pe "s/adminlab/$name/g" install-config.yaml.tmpl | base64 -w0)
  perl -pe "s/adminlab/$name/g" odf-cluster.yaml.tmpl |
    perl -pe "s/(\s+install-config.yaml\:\s*).*$/\$1$config/" > $yaml
  oc apply -f $yaml
  oc label ManagedCluster --overwrite=true -l name=$name workshop=ocp-odf-admin
done
