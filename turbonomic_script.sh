export NS=turbonomic
oc new-project ${NS}
oc project ${NS}

echo "Installing Turbonomic Platform Operator"
cat << EOF | oc -n ${NS} apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  annotations:
    olm.providedAPIs: Xl.v1.charts.helm.k8s.io
  name: turbonomic-mkk5d
  namespace: ${NS}
spec:
  targetNamespaces:
  - ${NS}
EOF

cat << EOF | oc -n ${NS} apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
   operators.coreos.com/t8c-certified.turbonomic: ""
  name: t8c-certified
  namespace: ${NS}
spec:
  name: t8c-certified
  source: certified-operators
  sourceNamespace: openshift-marketplace
EOF

echo "Creating an Instance"
touch describe
oc describe project ${NS} > describe
RANGE=$(grep -o -P '(?<=openshift\.io\/sa\.scc\.uid\-range=).*(?=\/)' describe)
cat << EOF | oc -n ${NS} apply -f -
apiVersion: charts.helm.k8s.io/v1
kind: Xl
metadata:
  name: xl-release
spec:
  # This configuration file is used for production.
  # Default values copied from <project_dir>/helm-charts/xl/values.yaml

  # Default values for xl.
  # This is a YAML-formatted file.
  # Declare variables to be passed into your templates.

  # Any changes run : kubectl apply -f deploy/crds/charts_v1alpha1_xl_cr.yaml -n turbonomic

  # Global settings
  global:
   securityContext:
     fsGroup: ${RANGE}
  #  registry: index.docker.io
  #  imageUsername: turbouser
  #  imagePassword: turbopassword
   repository: icr.io/cpopen/turbonomic
   tag: 8.8.1
   externalIP: 10.0.2.15
   externalDbIP: 10.0.2.15
   externalTimescaleDBIP: 10.0.2.15
   enableExternalSecrets: true
  grafana:
    # Grafana is disabled by default. To enable it, uncomment:
    enabled: false
    adminPassword: admin
    grafana.ini:
      database:
        # Store data in sqlite3 (no persistence across restarts) by default. To persist, uncomment:
        type: postgres
        password: grafana

  # Component selector - Probes
  actionscript:
    enabled: true
  actionstream-kafka:
    enabled: false
  appdynamics:
    enabled: true
  appinsights:
    enabled: true
  aws:
    enabled: true
  azure:
    enabled: true
  dynatrace:
    enabled: true
  gcp:
    enabled: true
  hpe3par:
    enabled: true
  horizon:
    enabled: false
  hyperflex:
    enabled: false
  hyperv:
    enabled: true
  ibmstorage-flashsystem:
    enabled: true
  kubeturbo:
    enabled: true
  netapp:
    enabled: true
  nutanix:
    enabled: true
  oneview:
    enabled: true
  prometheus-mysql-exporter:
    enabled: true
    mysql:
      user: root
      pass: vmturbo
  prometheus:
    enabled: true
  prometurbo:
    enabled: true
  pure:
    enabled: true
  scaleio:
    enabled: false
  servicenow:
    enabled: false
  ucs:
    enabled: true
  vcenter:
    enabled: true
  vmax:
    enabled: true
  vmm:
    enabled: true
  wmi:
    enabled: true
  snmp:
    enabled: true
  mssql:
    enabled: true
  mysql:
    enabled: false
  oracle:
    enabled: false
  tomcat:
    enabled: false
  jvm:
    enabled: false
  newrelic:
    enabled: true
  udt:
    enabled: true
  websphere:
    enabled: false
  weblogic:
    enabled: false
  xen:
    enabled: false
  instana:
    enabled: true
  jboss:
    enabled: false
EOF
until oc get crd xls.charts.helm.k8s.io >> /dev/null 2>&1; do sleep 5; done
