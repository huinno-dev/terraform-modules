# terraform-modules

Huinno 인프라 커스텀 Terraform 모듈.

## Overview

이 리포는 재사용 모듈만 담습니다. 실제 환경 배포(state, backend, 환경별 값)는 이 모듈을 `source`로 불러 쓰는 별도 리포에서 Terragrunt로 관리합니다.

각 모듈 디렉터리에는 모듈을 단독으로 `init`·`validate`·`plan` 해볼 수 있는 예제(`example/` 또는 `examples/`)가 있습니다.

## 모듈 목록

| 모듈 | 만드는 것 | 예제 |
|---|---|---|
| [ncloud/terraform-ncloud-vpc](modules/ncloud/terraform-ncloud-vpc) | VPC(또는 기존 VPC 재사용), Network ACL, public·private·LB·NAT 서브넷, NAT Gateway, 라우트 테이블 | [example](modules/ncloud/terraform-ncloud-vpc/example) |
| [ncloud/terraform-ncloud-acg](modules/ncloud/terraform-ncloud-acg) | ACG와 inbound/outbound 규칙 | [example](modules/ncloud/terraform-ncloud-acg/example) |
| [ncloud/terraform-ncloud-alb](modules/ncloud/terraform-ncloud-alb) | Load Balancer, 리스너, 타깃 그룹 | [example](modules/ncloud/terraform-ncloud-alb/example) |
| [ncloud/terraform-ncloud-public-ip](modules/ncloud/terraform-ncloud-public-ip) | 공인 IP (`prevent_destroy`). ALB 등과 수명을 분리해 재생성 시에도 같은 IP 유지 | [example](modules/ncloud/terraform-ncloud-public-ip/example) |
| [ncloud/terraform-ncloud-nas](modules/ncloud/terraform-ncloud-nas) | NAS 볼륨 | [example](modules/ncloud/terraform-ncloud-nas/example) |
| [ncloud/terraform-ncloud-nks](modules/ncloud/terraform-ncloud-nks) | NKS 클러스터, 노드풀, 액세스 항목(`auth_type = API`) | [example](modules/ncloud/terraform-ncloud-nks/example) |
| [ncloud/terraform-ncloud-nks-alb-ingress](modules/ncloud/terraform-ncloud-nks-alb-ingress) | NKS ALB Ingress Controller용 Ingress(ALB 1개 → 백엔드 Service), `alb` IngressClass 기본값 해제 | [example](modules/ncloud/terraform-ncloud-nks-alb-ingress/example) |
| [ncloud/terraform-ncloud-nks-auth](modules/ncloud/terraform-ncloud-nks-auth) | `CONFIG_MAP` 인증 클러스터의 `kube-system/ncp-auth` ConfigMap | [example](modules/ncloud/terraform-ncloud-nks-auth/example) |
| [aws/terraform-aws-vpc](modules/aws/terraform-aws-vpc) | VPC(또는 기존 VPC 재사용), IGW, public·private 서브넷, NAT Gateway, Flow Log | [example](modules/aws/terraform-aws-vpc/example) |
| [aws/terraform-aws-efs](modules/aws/terraform-aws-efs) | EFS 파일시스템, mount target, 전용 보안 그룹 | [example](modules/aws/terraform-aws-efs/example) |
| [aws/terraform-aws-eip](modules/aws/terraform-aws-eip) | AZ당 EIP 1개 | [example](modules/aws/terraform-aws-eip/example) |
| [aws/terraform-aws-data](modules/aws/terraform-aws-data) | 조회 전용: Route 53 zone ID, 호출자 계정 정보 | [example](modules/aws/terraform-aws-data/example) |
| [helm/terraform-helm](modules/helm/terraform-helm) | `apps` map 항목마다 Helm 릴리스 | [examples](modules/helm/terraform-helm/examples) |
| [argocd/terraform-argocd](modules/argocd/terraform-argocd) | Argo CD repository·project·application | [examples](modules/argocd/terraform-argocd/examples) |

## Requirements

| 항목 | 버전 |
|---|---|
| Terraform | `>= 1.5` |
| `NaverCloudPlatform/ncloud` | `>= 4.0` |
| `hashicorp/aws` | `>= 5.0` |
| `hashicorp/kubernetes` | `>= 2.0` (nks-auth), `>= 2.10` (nks-alb-ingress) |
| `hashicorp/helm` | `>= 3.0` |
| `argoproj-labs/argocd` | `>= 7.0` |

자격증명은 프로바이더 기본 방식을 따릅니다.

| 프로바이더 | 출처 |
|---|---|
| ncloud | 환경변수 `NCLOUD_ACCESS_KEY` / `NCLOUD_SECRET_KEY` (예제의 `ncloud_access_key` / `ncloud_secret_key` 변수로도 전달 가능) |
| aws | 환경변수 `AWS_PROFILE` 또는 `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` |

## Quick start

호출하는 쪽 리포에서 git 주소로 모듈을 참조합니다.

```hcl
module "vpc" {
  source = "git::https://github.com/huinno-dev/terraform-modules.git//modules/ncloud/terraform-ncloud-vpc?ref=<tag>"

  name            = "seoul-dev"
  cidr            = "10.110.0.0/16"
  azs             = ["KR-1", "KR-2"]
  private_subnets = ["10.110.52.0/22", "10.110.56.0/22"]
  public_subnets  = ["10.110.41.0/24", "10.110.42.0/24"]
}
```

> `<tag>`: 릴리스 태그 규칙은 TBD(리포 관리자 확정). 태그가 생기기 전까지는 `ref=main`이나 커밋 SHA를 씁니다.

## Usage

모듈마다 입력 예시는 각 예제 디렉터리의 `main.tf`가 기준입니다. 리포 전반에서 쓰는 패턴은 두 가지입니다.

**기존 리소스 재사용** — `terraform-ncloud-vpc`와 `terraform-aws-vpc`는 `vpc_id`를 넘기면 VPC를 새로 만들지 않고 그 VPC 안에 서브넷 등을 만듭니다.

**map 입력 + 공통 기본값** — `terraform-helm`과 `terraform-argocd`는 항목을 map으로 받고, `defaults`를 각 항목 아래에 깔아 줍니다.

```hcl
module "helm" {
  source = "git::https://github.com/huinno-dev/terraform-modules.git//modules/helm/terraform-helm?ref=<tag>"

  defaults = { atomic = true, wait = true, timeout = 600 }

  apps = {
    traefik = {
      repository = "https://traefik.github.io/charts"
      chart      = "traefik"
      version    = "41.6.1"
      namespace  = "traefik"
    }
  }
}
```

## Development

빌드 스크립트와 CI는 없습니다. 모듈을 고친 뒤 해당 모듈의 예제 디렉터리에서 확인합니다.

```bash
# 리포 루트에서
tofu fmt -recursive modules/

# 수정한 모듈의 예제 디렉터리에서
cd modules/aws/terraform-aws-vpc/example
tofu init -backend=false
tofu validate        # Success! The configuration is valid.
tofu plan            # 자격증명 필요, 실제 리소스를 조회
```

예제를 `apply`한 경우 같은 디렉터리에서 `tofu destroy`로 정리합니다. `.terraform/`, lock 파일, state는 `.gitignore`에 포함되어 있습니다.
