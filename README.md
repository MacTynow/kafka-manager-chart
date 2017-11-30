# Kafka manager helm chart

This chart let you install [Kafka manager](https://github.com/yahoo/kafka-manager)
on a Kubernetes cluster using the [kafka-manager-docker](https://github.com/sheepkiller/kafka-manager-docker)
image.

## Configuration

### Kafka clusters

This section allow you to configure which Kafka cluster the manager will
monitor. You can skip this step and configure this using the webUI, but
you will need to configure a Zookeeper backend (See below).

```yaml
kafka:
  clusters:
    - # You can embed any configuration you need, variables have the same
      # name than the web ui "Add Cluster" form variables.
      name: "default"
      # MANDATORY VALUE
      # Uri at which Kafka Zookeeper's can be contacted.
      zkHosts: "kafka-zookeeper:2181"
      kafkaVersion: "0.9.1"
```


### Zookeeper backend

Kafka manager need a `Zookeeper` cluster to work, this chart let you 2 options
for it's configuration :

1. Use the Kafka internal `Zookeeper` cluster (by default if you have configured your clusters) .
2. Use an external cluster (`values.yaml` entries below)

```yaml
kafkaManager:
  useKafkaZookeeper: false
  zkHosts: "some-zookeeper:2181"
```


## Deployment

1. Clone the repository
2. Configure the application by tweaking `values.yaml`
3. `helm install .`

Note that the helm installation/upgrade can be slow because the cluster configuration
must be done at runtime, we are thus using a helm `post-install` hook to send
cluster add requests from a `alpine-curl` image. Helm won't exit before the
`post-install` job succeeded.

If you are running into an `Error: timed out waiting for the condition`, this probably mean that the `kafka-manager` deployment isn't healthy,
thus preventing the hook termination.

### Accessing the application

Once the chart is deployed, it will give you some informations on how to access your application:

```
Access to the application using the ingress :
  http://kafka-manager.local

Access to the application using service :
  export POD_NAME=$(kubectl get pods --namespace default -l "app=kafka-manager,release=torpid-yak" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:9000

```
