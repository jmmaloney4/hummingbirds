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

const project = new digitalocean.Project("pulumi", {
    name: "Hummingbot",
    description: "A project to represent development resources.",
    environment: "Development",
    resources: [cluster.clusterUrn]
});

const provider = new kubernetes.Provider("do-k8s", { kubeconfig })
const appLabels = { "app": "hbot" };
const hbot = new kubernetes.apps.v1.Deployment("hbot", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 5,
        template: {
            metadata: { labels: appLabels },
            spec: {
                containers: [{
                    name: "hummingbot",
                    image: "hummingbot/hummingbot:latest",
                    stdin: true,
                    tty: true,
                }],
            },
        },
    },
}, { provider });
