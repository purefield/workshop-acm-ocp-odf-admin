Use the create cluster dialog in ACM with yaml/secrets shown but do not create the cluster. 
Name the cluster adminlab.
Export the yaml into your main template file (odf-cluster.tmpl.yaml) and 
extract the install-config.yaml value into a separate template files (install-config.tmpl.yaml).
Review and configure # of instances then run clone.sh



# get number of instances - update cluster pool template
   oc new-project ocp-odf-workshop-davita
   oc apply -f cluster-pool.yaml
   # create htpassd auth provider - admin user
   oc adm policy add-cluster-role-to-user cluster-admin admin
   oc adm policy add-role-to-user admin admin -n lab-ocp-cns

use simple password - openshift
generate unique cluster names

random cluster name (8char alphanumeric) - static username/password for each instance

add local admin user passwords and cluster name to hub cluster secret in cluster namespace and share with cluster using subscription
use ACM to distribute secrets
clone clusters based on number of instances using ACM cluster pools and apply label to clusters for workshop
configure cluster for htpass using ACM policies
add user to each instance for a user with cluster-admin role with ACM

share credentials with workshop participants
