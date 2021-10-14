. /srv/login.sh
oc-login 1
for id in $(seq -w 01 1); do
  yaml=odf-cluster.user$id.yaml
  config=$(perl -pe "s/adminlab/user$id/g" install-config.yaml.tmpl | base64 -w0)
  perl -pe "s/adminlab/user$id/g" odf-cluster.yaml.tmpl |
    perl -pe "s/(\s+install-config.yaml\:\s*).*$/\$1$config/" > $yaml
  oc apply -f $yaml
done
