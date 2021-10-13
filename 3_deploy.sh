prefix=user
home=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
. /srv/login.sh
oc-login 1
deployments=''
for cluster in $(oc get ManagedCluster -o name | cut -d\/ -f2 | sort -n | egrep "^$prefix"); do
  secret=$(oc get secret -n $cluster -l hive.openshift.io/secret-type=kubeadmincreds -o json | jq -r '.items[0].data.password' | base64 -d)
  base_url="$cluster.$(oc get ClusterDeployment -n $cluster -o=jsonpath='{.items[0].spec.baseDomain}')"
  su - -c "$(printf '%s/deployment/setup.sh %s %s %s\n' "$home" "$cluster" "$base_url" "$secret")" > $cluster.log &
done
