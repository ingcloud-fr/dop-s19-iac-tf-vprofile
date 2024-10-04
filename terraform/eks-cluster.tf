# Déclaration d'un module Terraform pour créer un cluster EKS (Elastic Kubernetes Service) sur AWS
module "eks" {
  # Spécifie la source du module EKS. Ici, on utilise un module officiel Terraform disponible sur le registre
  # terraform-aws-modules. La version utilisée est la 19.19.1.
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  # Nom du cluster EKS à créer. Ce nom est défini dans une variable locale "local.cluster_name".
  cluster_name    = local.cluster_name

  # Version du cluster Kubernetes (ici, 1.27) à déployer sur AWS.
  cluster_version = "1.27"

  # ID du VPC dans lequel le cluster EKS sera déployé. Ce VPC est défini par le module VPC.
  vpc_id = module.vpc.vpc_id

  # Liste des sous-réseaux privés où les nœuds du cluster seront déployés. Ceux-ci proviennent du module VPC.
  subnet_ids = module.vpc.private_subnets

  # Détermine si le point de terminaison API du cluster sera accessible publiquement. Ici, il est activé.
  cluster_endpoint_public_access = true

  # Configuration par défaut pour les groupes de nœuds gérés par EKS.
  eks_managed_node_group_defaults = {
    # Type d'AMI (Amazon Machine Image) utilisé par les nœuds. Ici, on utilise une AMI pour AL2 (Amazon Linux 2) avec architecture x86_64.
    ami_type = "AL2_x86_64"
  }

  # Définition des groupes de nœuds gérés (Managed Node Groups) pour le cluster EKS.
  eks_managed_node_groups = {
    # Premier groupe de nœuds (node group 1)
    one = {
      # Nom du groupe de nœuds
      name = "node-group-1"

      # Types d'instances EC2 utilisées par ce groupe de nœuds. Ici, des instances de type t3.small.
      instance_types = ["t3.small"]

      # Configuration des tailles pour l'auto-scaling du groupe de nœuds
      min_size     = 1  # Nombre minimum de nœuds
      max_size     = 3  # Nombre maximum de nœuds
      desired_size = 2  # Taille désirée du groupe au démarrage
    }

    # Deuxième groupe de nœuds (node group 2)
    two = {
      name = "node-group-2"

      # Type d'instance et taille de scaling pour ce groupe de nœuds (également des t3.small).
      instance_types = ["t3.small"]

      min_size     = 1  # Nombre minimum de nœuds
      max_size     = 2  # Nombre maximum de nœuds
      desired_size = 1  # Taille désirée du groupe au démarrage
    }
  }
}
