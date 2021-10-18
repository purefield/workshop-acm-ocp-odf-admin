prefix='(lab-ocp-cns-|user)'
home=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
. /srv/login.sh
oc-login 1
cd multi-cloud
oc apply -f namespace.yaml -f secrets.yaml -f application.yaml -f channel.yaml -f subscription.yaml -f placementrule.yaml -f policy.yaml
cd -
for cluster in $(oc get ManagedCluster -o name | cut -d\/ -f2 | sort -n | egrep "^$prefix"); do
  secret=$(oc get secret -n $cluster -l hive.openshift.io/secret-type=kubeadmincreds -o json | jq -r '.items[0].data.password' | base64 -d)
  base_url="$cluster.$(oc get ClusterDeployment -n $cluster -o=jsonpath='{.items[0].spec.baseDomain}')"
  perl -pe "s/\{BASE_URL\}/$base_url/g" dashboard-secrets.yaml.tmpl |
    perl -pe "s/\{CLUSTER_NAME\}/$cluster/g" |
    perl -pe "s/\{KUBEADMIN_PASSWORD\}/$secret/g" |
    perl -pe 's/(\w)(--)/$1\\\\${2}/g' | oc apply -f -
done
