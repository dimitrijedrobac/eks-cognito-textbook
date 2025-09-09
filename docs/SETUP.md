This project provisions an Amazon EKS cluster with Terraform, deploys the Guestbook app via Helm, and secures it using Amazon Cognito authentication through the AWS Load Balancer Controller.
All infrastructure and deployments are managed as Infrastructure as Code (IaC).

######################################

eks-cognito-guestbook/
├─ infra/
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  ├─ providers.tf
│  ├─ modules/
│  │  ├─ vpc/
│  │  ├─ eks/
│  │  ├─ iam-irsa/
│  │  └─ cognito/
│  └─ envs/dev/terraform.tfvars
├─ charts/
│  └─ guestbook/
│     ├─ Chart.yaml
│     ├─ values.yaml
│     └─ templates/
│        ├─ deployment.yaml
│        ├─ service.yaml
│        └─ ingress.yaml
├─ docs/SETUP.md

######################################
Prerequisites
######################################

AWS Account + IAM access
Terraform ≥ 1.3
kubectl
Helm ≥ 3.0
jq (for JSON manipulation)
AWS CLI v2

######################################
Step 1: Provision Infrastructure
######################################

Initialize Terraform:

cd infra
terraform init

Apply the configuration:

terraform apply -var-file=envs/dev/terraform.tfvars

Outputs include:

cluster_name, cluster_endpoint, cluster_ca_certificate

VPC and subnet IDs

Cognito user pool ID, client ID, and domain

OIDC provider ARN

######################################
Step 2: Configure kubectl
######################################

REGION=$(terraform output -raw region)
CLUSTER=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region $REGION --name $CLUSTER

Verify access:
kubectl get nodes

######################################
Step 3: AWS Load Balancer Controller (IRSA)
######################################

 - Created a dedicated IAM role (alb-controller-irsa) with trust policy bound to EKS OIDC.
 - Attached required IAM policy: AmazonEKSLoadBalancerControllerPolicy.

Helm install
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.alb_irsa_role_arn
  }
}

######################################
Step 4: Cognito Setup
######################################
- Cognito user pool
- Cognito app client (no secret)
- Cognito hosted UI domain
- Updated client with:

aws cognito-idp update-user-pool-client \
  --user-pool-id <POOL_ID> \
  --client-id <CLIENT_ID> \
  --callback-urls "https://<ALB_HOST>/oauth2/idpresponse" \
  --logout-urls   "https://<ALB_HOST>/logout" \
  --allowed-o-auth-flows-user-pool-client \
  --allowed-o-auth-flows code \
  --allowed-o-auth-scopes openid \
  --supported-identity-providers COGNITO

######################################
  Step 5: Guestbook App
######################################
- Helm chart includes:
- Deployment: frontend replicas
- Service: ClusterIP
- Ingress: ALB with Cognito annotations
- Example Ingress annotations:
    alb.ingress.kubernetes.io/auth-type: cognito
    alb.ingress.kubernetes.io/auth-on-unauthenticated-request: authenticate
    alb.ingress.kubernetes.io/auth-idp-cognito: >
        {"userPoolArn":"<poolArn>",
        "userPoolClientId":"<clientId>",
        "userPoolDomain":"<domainPrefix>"}

######################################
Step 6: Test
######################################
Get ALB DNS:

kubectl -n guestbook get ingress guestbook \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'


Open in browser:
- You should be redirected to Cognito Hosted UI.
- After login, Guestbook frontend appears.


######################################
Step 7: Troubles Faced & Fixes
######################################
- Terraform version conflicts → Fixed by upgrading to v1.13.
- Provider constraints mismatch → Cleaned .terraform.lock.hcl and re-ran init -upgrade.
- cluster_addons unexpected attribute → Updated to addons block syntax.
- Node group unhealthy → Switched to Bottlerocket AMI type and ensured correct subnets.
- IAM access denied → Used enable_cluster_creator_admin_permissions = true and explicit aws_eks_access_entry.
- Ingress conflicts → Cleaned up Helm release ownership metadata (kubectl delete ingressclassparams / helm uninstall).
- IRSA issues → Created a fresh IAM role (alb-controller-irsa) with correct OIDC trust.
- Cognito domain conflict → Avoided using reserved word cognito.
- Callback URLs empty → Re-applied Cognito client update with ALB hostname.
- DNS resolution issues → Re-flushed local resolver and re-ran update-kubeconfig.

######################################
Cleanup
######################################
terraform destroy -var-file=envs/dev/terraform.tfvars


This tears down:
- VPC
- EKS cluster
- Cognito resources
- Helm releases (Guestbook + ALB controller)

######################################
⚡ End Result:
A fully working Cognito-secured Guestbook app on EKS, deployed entirely via Terraform + Helm, with all IAM/OIDC/IRSA wiring automated.
######################################


PS.
Only thing not possible is to get to app via browser becouse Cognito requires HTTPS and that is only possible via Route53.
Its required to get a Domain name and TLS certificate to make HTTP connection to Cognito.