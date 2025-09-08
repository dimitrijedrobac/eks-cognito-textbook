resource "kubernetes_namespace" "guestbook" {
  metadata { name = "guestbook" }
}

resource "helm_release" "guestbook" {
  name       = "guestbook"
  namespace  = kubernetes_namespace.guestbook.metadata[0].name
  chart      = "${path.module}/../charts/guestbook"   # local chart path

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [
    yamlencode({
      service = {
        name       = "guestbook"
        port       = 80
        targetPort = 80
      }
      ingress = {
        enabled   = true
        className = "alb"
        annotations = {
          scheme                     = "internet-facing"
          targetType                 = "ip"
          authOnUnauthenticatedRequest = "authenticate"
          authSessionCookie          = "alb-auth"
          authSessionTimeout         = "3600"
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
    helm_release.aws_load_balancer_controller,  # ensure ALB controller is ready
  ]
}
