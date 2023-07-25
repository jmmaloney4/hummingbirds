import * as pulumi from "@pulumi/pulumi";
import * as eks from "@pulumi/eks";
import * as awsnative from "@pulumi/aws-native";
import * as aws from "@pulumi/aws";

const config = new pulumi.Config();

const provider = new aws.Provider("aws", {
    region: aws.Region.USEast2,
    accessKey: config.require("accessKey"),
    secretKey: config.require("secretKey") 
});

const cluster = new eks.Cluster("cluster");
export const kubeconfig = cluster.kubeconfig;
