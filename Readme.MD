# Using Kubernetes to Perform Operations on GCP Compute Engines

![kubernetes-cronjob-monitor-linux-service-with-phone-call-alert-sequence-diagram](./sequence-diagram-of-article.png)

We often come across requirements when kubernetes workloads need to do batch operations or maintaince or monitoring operation on services running inside compute engines in gcp so we will one example of how we can use kubernetes cronjobs which will monitor the mysql service running in side compute engine or small set of compute engines and trigger a phone call alert with simple shell script.

This guide will walk you through setting up a system that ensures your MySQL servers are always running smoothly, and alerts you immediately if any issues arise. While we’ve chosen a specific stack for this tutorial, feel free to mix and match components to suit your needs and achieve similar results. The goal is simply explain how you can leverage kubernetes to perform operations on compute engines.

### Prerequisites

1. git,kubectl,gcloud should be installed on your machine
2. compute engine and kubernetes engine access to your GCP user

Let's get started with each step, one by one!

#### Clone Repository
```
git clone https://github.com/Mitesh-Gangaramani/linux-service-phone-call-alert.git
```

#### Generate SSH keys and use them for authentication

We need an SSH key to log in to the compute engine, so let's create a key pair. This will give us both a public key and a private key.

```
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa_k8s_cronjob
```

#### Add the public key to the Compute Engine instance

We need to add the public key id_rsa_k8s_cronjob.pub (which we generated in the previous step) to each compute engine instance. This will allow connections from the Kubernetes CronJob.

```
gcloud compute instances add-metadata <INSTANCE_NAME> --metadata-from-file ssh-keys=~/.ssh/id_rsa_k8s_cronjob.pub
```

#### Add ssh key as kubernetes secret

To securely connect to your MySQL servers, we'll store SSH keys in Kubernetes secrets. This way, your credentials are safely managed and only accessible to the pods that need them. We'll create all resources inside the mitesh-test namespace.

````
kubectl create secret generic mysql-secret-keys --from-file=~/.ssh/id_rsa_k8s_cronjob -n mitesh-test
````

#### Create configmap

Let's add this configmap to store the configuration, and we'll include it in our Kubernetes YAML manifest.

```
kubectl create configmap mysql-monitoring-configmap --from-file=service-monitor-script.sh -n mitesh-test
```

#### Create the cronjob with desired schedule

We will volume mount our configmap and Kubernetes secret that we created earlier, along with the cronjob schedule. You can use any Linux distribution image that has curl installed.

```
kubectl create -f mysql-monitoring-cron.yaml
```

We just looked at an example of monitoring a specific Linux service. However, you can use this approach with any stack you prefer.

