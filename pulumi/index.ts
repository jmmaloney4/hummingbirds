import * as pulumi from "@pulumi/pulumi";
import * as digitalocean from "@pulumi/digitalocean";
import * as kubernetes from "@pulumi/kubernetes";

const cluster = new digitalocean.KubernetesCluster("do-cluster", {
    region: digitalocean.Region.NYC3,
    version: "latest",
    nodePool: {
        name: "default",
        size: digitalocean.DropletSlug.DropletS2VCPU2GB,
        nodeCount: 2,
    },
});

export const kubeconfig = cluster.kubeConfigs[0].rawConfig;

// const db = new digitalocean.DatabaseCluster("hummingbot-db", {
//     engine: "pg",
//     version: "15",
//     size: digitalocean.DatabaseSlug.DB_1VPCU1GB,
//     region: "nyc1",
//     nodeCount: 1,
//     tags: ["production"],
// });

const provider = new kubernetes.Provider("do-k8s", { kubeconfig })

const appLabels = { "app": "hummingbot" };
const app = new kubernetes.apps.v1.Deployment("hummingbot", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: {
                containers: [{
                    name: "hummingbot",
                    image: "hummingbot/hummingbot:latest",
                    tty: true,
                    stdin: true,
                }],
            },
        },
    },
}, { provider });
// const appService = new kubernetes.core.v1.Service("do-app-svc", {
//     spec: {
//         type: "LoadBalancer",
//         selector: app.spec.template.metadata.labels,
//         ports: [{ port: 80 }],
//     },
// }, { provider });

// export const ingressIp = appService.status.loadBalancer.ingress[0].ip;