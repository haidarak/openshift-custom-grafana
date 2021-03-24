Create a custom grafana to monitor OCP 4.x Cluster
------------------------------------------------

Source : https://www.redhat.com/en/blog/custom-grafana-dashboards-red-hat-openshift-container-platform-4 & https://access.redhat.com/

- Add grafana community operator to the cluster
- Deploy grafana to your selected project


- Add new user for your grafana monitoring

-- Go to openshift-monitoring project
oc project openshift-monitoring

-- get the current password (this command works if you use linux OS and have htpasswd installed)
oc get secret prometheus-k8s-htpasswd -o jsonpath='{data.auth}' | base64 -d > /tmp/htpasswd-temp
echo >> /tmp/htpasswd-temp #
-- create the new user
htpasswd -s -b /ymp/htpasswd-tmp <username> <password>

-- patch auth file
oc patch secret prometheus-k8s-htpasswd -p "{\"data\":{\"auth\":\"$(base64 -w0 /tmp/htpasswd-tmp)\"}}"
oc delete pod -l app=prometheus

-- create a new datasource in grafana

    apiVersion: integreatly.org/v1alpha1
    kind: GrafanaDataSource
    metadata:
      name: example-grafanadatasource
    spec:
      datasources:
        - basicAuthUser: <username>
          access: proxy
          editable: true
          secureJsonData:
            basicAuthPassword: <password>
          name: Prometheus
          url: 'https://prometheus-k8s.openshift-monitoring.svc.cluster.local:9091'
          jsonData:
            timeInterval: 5s
            tlsSkipVerify: true
          basicAuth: true
          isDefault: true
          version: 1
          type: prometheus
      name: example-datasources.yaml

IF THAT DOESN'T WORK
-- Grant cluster monitoring view to grafana 
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount

-- Get openshift cluster monitoring service account token
oc -n openshift-monitoring serviceaccounts get-token grafana-serviceaccount 

-- create new datasource file
    { 
        "name": "ocp", 
        "type": "prometheus", 
        "typeLogoUrl": "", 
        "access": "proxy", 
        "url": "<url>", 
        "basicAuth": false, 
        "withCredentials": false, 
        "jsonData": { 
            "tlsSkipVerify":true, 
            "httpHeaderName1":"Authorization" 
        }, 
        "secureJsonData": { 
            "httpHeaderValue1":"Bearer <SA token>" 
        } 
    } 
    
example : 
    { 
        "name": "ocp", 
        "type": "prometheus", 
        "typeLogoUrl": "", 
        "access": "proxy", 
        "url": 'https://thanos-querier.openshift-monitoring.svc.cluster.local:9091', 
        "basicAuth": false, 
        "withCredentials": false, 
        "jsonData": { 
            "tlsSkipVerify":true, 
            "httpHeaderName1":"Authorization" 
        }, 
        "secureJsonData": { 
            "httpHeaderValue1":"Bearer <SA token>" 
        } 
    } 
    
