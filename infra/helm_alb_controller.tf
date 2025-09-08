resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"


  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

 
  values = [
    yamlencode({
      clusterName = module.eks.cluster_name
      region      = var.region
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = var.alb_irsa_role_arn
        }
      }
    })
  ]

  depends_on = [ module.eks ]
}
