resource "kubernetes_namespace" "guestbook" {
  metadata { name = "guestbook" }
}


resource "helm_release" "guestbook" {
  name      = "guestbook"
  namespace = kubernetes_namespace.guestbook.metadata[0].name
  chart     = "${path.module}/../charts/aws-load-balancer-controller"  # local path


  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      ingress = {
        enabled   = true
        className = "alb"
        annotations = {
          scheme                 = "internet-facing"
          targetType             = "ip"
          authOnUnauthenticatedRequest = "authenticate"
          authSessionCookie      = "alb-auth"
          authSessionTimeout     = "3600"
        }
      }
      cognito = {
        userPoolArn      = module.cognito.user_pool_arn
        userPoolClientId = module.cognito.user_pool_client_id
        userPoolDomain   = module.cognito.user_pool_domain
      }
    })
  ]

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller,  
        kubernetes_namespace.guestbook
  ]
}
