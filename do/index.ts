import * as pulumi from "@pulumi/pulumi";
import * as digitalocean from "@pulumi/digitalocean";
import * as kubernetes from "@pulumi/kubernetes";

const cluster = new digitalocean.KubernetesCluster("do-cluster", {
    region: digitalocean.Region.NYC3,
    version: "1.27.4-do.0",
    nodePool: {
        name: "default",
        size: digitalocean.DropletSlug.DropletS2VCPU2GB,
        nodeCount: 1,
    },
});

export const kubeconfig = cluster.kubeConfigs[0].rawConfig;

const db = new digitalocean.DatabaseCluster("hummingbot", {
    engine: "pg",
    nodeCount: 1,
    region: digitalocean.Region.NYC1,
    size: digitalocean.DatabaseSlug.DB_1VPCU1GB,
    version: "15",
});

const project = new digitalocean.Project("pulumi", {
    name: "Hummingbot",
    description: "A project to represent development resources.",
    environment: "Development",
    resources: [cluster.clusterUrn, db.clusterUrn]
});

const provider = new kubernetes.Provider("do-k8s", { kubeconfig })
const appLabels = { "app": "hbot" };

const pvc = new kubernetes.core.v1.PersistentVolumeClaim("hbot-pvc", {
    spec: {
        accessModes: [ "ReadWriteOnce" ],
        storageClassName: "do-block-storage",
        resources: {
            requests: {
                storage: "5Gi"   
            }
        }
    }
}, { provider: provider });

const hbot = new kubernetes.apps.v1.Deployment("hbot", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: {
                containers: [{
                    name: "hummingbot",
                    image: "hummingbot/hummingbot:latest",
                    stdin: true,
                    tty: true,
                    volumeMounts: [
                        {
                            name: "logs",
                            mountPath: "/home/hummingbot/logs"
                        }   
                    ]
                }],
                volumes: [
                    {
                        name: "logs",
                        persistentVolumeClaim: {
                            claimName: pvc.metadata.name
                        }
                    }
                ]
            },
        },
    },
}, { provider });

