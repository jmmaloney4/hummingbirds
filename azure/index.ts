import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import * as azuread from "@pulumi/azuread";
import * as tls from "@pulumi/tls";
import * as random from "@pulumi/random";

const config = new pulumi.Config();
// const provider = new azure.Provider("azure", {
    
// });

// Create an Azure Resource Group
const resourceGroup = new azure.resources.ResourceGroup("aks-pulumi-test");

// Create an AD service principal
const adApp = new azuread.Application("aks", {
    displayName: "aks",
});
const adSp = new azuread.ServicePrincipal("aksSp", {
    applicationId: adApp.applicationId,
});

// Create the Service Principal Password
const adSpPassword = new azuread.ServicePrincipalPassword("aksSpPassword", {
    servicePrincipalId: adSp.id,
    endDate: "2099-01-01T00:00:00Z",
});

// Generate an SSH key
const sshKey = new tls.PrivateKey("ssh-key", {
    algorithm: "RSA",
    rsaBits: 4096,
});

const managedClusterName = config.get("managedClusterName") || "azure-aks";
const cluster = new azure.containerservice.ManagedCluster(managedClusterName, {
    resourceGroupName: resourceGroup.name,
    agentPoolProfiles: [{
        count: 3,
        maxPods: 110,
        mode: "System",
        name: "agentpool",
        nodeLabels: {},
        osDiskSizeGB: 30,
        osType: "Linux",
        type: "VirtualMachineScaleSets",
        vmSize: "Standard_DS2_v2",
    }],
    dnsPrefix: resourceGroup.name,
    enableRBAC: true,
    kubernetesVersion: "1.27.1",
    linuxProfile: {
        adminUsername: "testuser",
        ssh: {
            publicKeys: [{
                keyData: sshKey.publicKeyOpenssh,
            }],
        },
    },
    nodeResourceGroup: `MC_azure-go_${managedClusterName}`,
    servicePrincipalProfile: {
        clientId: adApp.applicationId,
        secret: adSpPassword.value,
    },
});

const creds = azure.containerservice.listManagedClusterUserCredentialsOutput({
    resourceGroupName: resourceGroup.name,
    resourceName: cluster.name,
});

const encoded = creds.kubeconfigs[0].value;
export const kubeconfig = pulumi.secret(encoded.apply(enc => Buffer.from(enc, "base64").toString()));