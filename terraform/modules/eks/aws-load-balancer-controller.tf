module "aws_load_balancer_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.8.1"

  name = "${var.cluster_name}-aws-lbc"

  attach_aws_lb_controller_policy = true

  associations = {
    controller = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = var.tags
}
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.14.0"

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name

      region = var.aws_region
      vpcId  = var.vpc_id

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }

      replicaCount = 2
    })
  ]

  depends_on = [
    module.aws_load_balancer_controller_pod_identity
  ]
}