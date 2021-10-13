cluster="$1"
base_url="$2"
secret="$3"
# echo "$cluster, $base_url, $secret"
home=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
cd $home
oc login --insecure-skip-tls-verify=true -u kubeadmin -p $secret https://api.$base_url:6443 2>&1 > /dev/null;
current_cluster=$($(which oc) whoami --show-server | cut -d. -f2)
if [[ "$cluster" == "$current_cluster" ]]; then
  echo "Logged into: $cluster"
  oc apply -f namespace.yaml
  for file in route.yaml configmap.yaml; do
  perl -pe "s/\{BASE_URL\}/$base_url/g" $file.tmpl |
    perl -pe "s/\{KUBEADMIN_PASSWORD\}/$secret/g" > $cluster.yaml.all
  done
  cat *.yaml >> $cluster.yaml.all
  sleep 5
  oc apply -f $cluster.yaml.all
  # rm -f $cluster.yaml.all
else
  echo "something went wrong with logging into $cluster"
fi
cd -
