# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 개요

Huinno 인프라용 Terraform 커스텀 모듈 모음입니다. 루트 모듈(배포 단위)은 여기 없고, 다른 리포에서 Terragrunt로 이 모듈들을 불러 씁니다. 로컬에는 `tofu`와 `terragrunt`가 설치되어 있고 `terraform` 바이너리는 없습니다(`.terraform` 아래 프로바이더도 `registry.opentofu.org`에서 받은 것).

레이아웃: `modules/<provider>/terraform-<provider>-<name>/`
- `ncloud/` — 네이버 클라우드 VPC 환경(vpc, acg, alb, nas, public-ip, mysql, redis, nks, nks-auth, nks-alb-ingress, cert)
- `aws/` — vpc, efs, eip, data(조회 전용)
- `helm/`, `argocd/` — 클러스터 위에 올리는 릴리스/애플리케이션

## 검증 명령

빌드·테스트 프레임워크나 CI 설정은 없습니다. 모듈 변경은 해당 모듈의 예제 디렉터리에서 검증합니다(ncloud·aws는 `example/`, helm·argocd는 `examples/`). 예제는 `source = "../"`로 상위 모듈을 참조합니다.

```bash
tofu fmt -recursive modules/                          # 포맷
cd modules/ncloud/terraform-ncloud-vpc/example
tofu init -backend=false && tofu validate              # 단일 모듈 검증
tofu plan                                              # 실제 클라우드 자격증명 필요
```

ncloud 예제의 `provider.tf`는 `ncloud_access_key`/`ncloud_secret_key` 변수를 받습니다(기본값 빈 문자열 → 환경변수 `NCLOUD_ACCESS_KEY`/`NCLOUD_SECRET_KEY` 사용). `terraform-aws-vpc` validate 시 `ipv6_cidr_block` deprecated 경고가 나오는 것은 기존 동작입니다.

## 모듈 작성 규약

- 파일 분할: `main.tf`, `variables.tf`, `outputs.tf`, `locals.tf`, `versions.tf`, 데이터소스는 `data.tf` 또는 `datas.tf`(모듈마다 다름 — 기존 이름을 따를 것).
- `versions.tf`: `required_version = ">= 1.5"`, 프로바이더는 하한만 지정(`ncloud >= 4.0`, `aws >= 5.0`, `helm >= 3.0`, `argocd >= 7.0`, `argoproj-labs/argocd` 네임스페이스).
- **"기존 리소스 재사용 또는 생성" 패턴** (ncloud/aws vpc): `create_vpc = var.vpc_id == ""`로 리소스를 `count` 생성하고, 이후 모든 참조는 `data "ncloud_vpc" "this"`(생성분 또는 전달된 ID)를 거칩니다. 리소스를 직접 참조하지 말고 data 소스를 쓰세요.
- **map 기반 다중 리소스 패턴** (helm, argocd): `var.apps`/`repos`/`projects`는 느슨한 `any` map이고, `locals.tf`에서 `merge(var.defaults, v)`로 기본값을 한 번 깔아둔 뒤 `main.tf`에서는 모든 인자를 `try(each.value.x, null)`로 읽습니다. 선택적 중첩 블록은 `dynamic` + `for_each = try([x], [])`. 새 인자를 추가할 때도 같은 방식으로.
- 하위호환 유지: 프로바이더 업그레이드로 인터페이스가 바뀐 경우 locals에서 옛 형태를 정규화합니다(예: helm 3.x의 `set` 리스트 속성이 map 입력도 받도록, argocd의 `repo_url` 단일 소스 축약형 → `sources`, `repo` → `source_repos`). 기존 입력 형태를 깨지 않도록 주의.
- 비자명한 클라우드 제약은 코드 주석으로 남깁니다(기존 주석 밀도 유지).

## NCloud 특이사항

- NAT Gateway는 `usage_type = "NATGW"`인 전용 PUBLIC 서브넷(`nat_subnets`)이 필요하고 공인 IP를 자체 할당합니다. LB 서브넷은 `usage_type = "LOADB"`(private `lb_subnets` / public `public_lb_subnets`).
- NKS: public·gov 사이트에서는 `lb_public_subnet_no`가 필수 → VPC 모듈의 `public_lb_subnets` 출력과 연결. 컨트롤 플레인 스펙 코드는 하이퍼바이저(XEN/RHV/KVM)별로 `locals.cluster_types`에 매핑. 노드풀 이미지/스펙은 범용 `ncloud_server_image`가 아니라 `ncloud_nks_server_images`/`ncloud_nks_server_products`로 조회해야 함. 인증은 기본 `auth_type = API`이고 권한은 `access_entries`(ncloud API)로 준다. Terraform으로 만들면 생성자가 관리자로 자동 등록되지 않아 `access_entries`가 비면 precondition으로 막는다. `CONFIG_MAP` 클러스터의 `ncp-auth` ConfigMap은 kubernetes 프로바이더가 필요해서 `terraform-ncloud-nks-auth` 모듈(별도 Terragrunt 유닛, nks 출력을 dependency로 받음)로 분리했다. nks 모듈에 kubernetes 리소스를 다시 넣지 말 것.
- **`terraform-ncloud-cert`는 지원 종료**(NCloud classic 인증서 리소스 지원 종료, 프로바이더 4.x에 없음). 코드는 이력 참고용으로만 유지합니다. VPC 인증서는 Certificate Manager에서 Terraform 밖으로 등록하고 `certificateNo`만 ALB 리스너의 `ssl_certificate_no`나 NKS Service 어노테이션으로 주입합니다. 자세한 내용은 [modules/ncloud/terraform-ncloud-cert/README.md](modules/ncloud/terraform-ncloud-cert/README.md). 이 모듈을 고치거나 다른 모듈에서 참조하지 마세요.

## 주의

- `.gitignore`가 `.terraform/`, `.terraform.lock.hcl`, state, `*.pem`/`*.key`를 제외합니다. 모듈은 프로바이더 버전을 고정하지 않으므로 lock 파일은 호출 측 리포의 몫입니다. 예제를 `init`해서 생긴 캐시는 커밋하지 않습니다.
- 모듈을 추가·삭제하거나 용도가 바뀌면 루트 [README.md](README.md)의 모듈 목록 표도 함께 갱신합니다.
