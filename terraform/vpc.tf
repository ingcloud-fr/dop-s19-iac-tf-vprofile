module "vpc" {
  # Source du module VPC depuis le registre Terraform. Le module permet de créer une infrastructure réseau complète sur AWS.
  source  = "terraform-aws-modules/vpc/aws"
  
  # Version du module VPC utilisé.
  version = "5.1.2"

  # Nom du VPC à créer. Ici, il est nommé "vprofile-eks" pour correspondre à un cluster EKS.
  name = "vprofile-eks"

  # CIDR du VPC. Le bloc d'adresses IP attribué au réseau est 172.20.0.0/16.
  cidr = "172.20.0.0/16"
  
  # Zones de disponibilité (AZs) où le VPC sera déployé. Le code sélectionne les trois premières zones disponibles.
  # data.aws_availability_zones.available.names provient d'une data source dans main.tf
  # azs = [..., ..., ...] c'est une liste
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  # Sous-réseaux privés dans les AZs spécifiées. Ces sous-réseaux seront utilisés pour les ressources non accessibles publiquement.
  private_subnets = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]

  # Sous-réseaux publics dans les mêmes AZs. Ces sous-réseaux sont utilisés pour les ressources accessibles publiquement comme les load balancers.
  public_subnets  = ["172.20.4.0/24", "172.20.5.0/24", "172.20.6.0/24"]

  # Active une passerelle NAT (Network Address Translation) pour permettre aux instances dans les sous-réseaux privés d'accéder à Internet.
  enable_nat_gateway   = true

  # Utilise une seule passerelle NAT au lieu d'une par zone de disponibilité, ce qui est plus économique.
  single_nat_gateway   = true

  # Active les noms DNS pour les instances lancées dans le VPC, ce qui est utile pour les connexions avec des noms d'hôtes.
  enable_dns_hostnames = true

  # Active le service de résolution DNS dans le VPC pour que les instances puissent résoudre des noms d'hôtes
  #enable_dns_support   = true 

  # Tags pour les sous-réseaux publics. 
  # Le tag "kubernetes.io/cluster" indique que ces sous-réseaux sont partagés par un cluster Kubernetes.
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1 # Tag pour indiquer qu'ils sont destinés aux ELB (Elastic Load Balancers)
  }

  # Tags pour les sous-réseaux privés. 
  # Le tag "kubernetes.io/role/internal-elb" indique que ces sous-réseaux sont destinés aux Load Balancers internes.
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1 # Tag pour indiquer l'utilisation d'ELB internes
  }
}
