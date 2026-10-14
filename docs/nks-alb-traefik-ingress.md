# NKS ALB Ingress + Traefik 구성 가이드

> **목적**: NKS ALB Ingress Controller가 만든 ALB 한 대로 외부 트래픽을 받아 Traefik으로 넘기고, 앱 라우팅은 Traefik에서 처리한다
> **대상**: NKS 클러스터에 인그레스 진입점을 구성하는 인프라 엔지니어
> **담당**: TBD (인프라 담당 확정 필요) | **갱신 조건**: Traefik 차트 메이저 버전 변경, ALB Ingress Controller 버전 변경, 클러스터 Kubernetes 1.36 업그레이드(`pause` 사용 가능)
> **버전**: v1.1 | **작성일**: 2026-10 | **기준**: NKS gov 사이트 KVM 클러스터, ALB Ingress Controller 0.14.0, Traefik 차트 41.6.1 (Traefik v3.7.13)

---

## 목차

- [구성 개요](#구성-개요)
- [전제 조건](#전제-조건)
- [ALB Ingress Controller 설치](#alb-ingress-controller-설치)
- [Traefik 설치](#traefik-설치)
- [IngressClass 정리](#ingressclass-정리)
- [ALB Ingress 생성](#alb-ingress-생성)
- [앱 Ingress 작성](#앱-ingress-작성)
- [사후 검증](#사후-검증)
- [운영 규칙](#운영-규칙)
- [롤백](#롤백)
- [트러블슈팅](#트러블슈팅)
- [검토 이력 및 의사결정](#검토-이력-및-의사결정)

---

## 구성 개요

Ingress Controller 두 개가 역할을 나눕니다. ALB Ingress Controller는 **ALB를 만드는 일만**, Traefik은 **앱 라우팅만** 맡습니다.

```
 [제어 경로]
   Ingress traefik/traefik-alb (class: alb) ──watch──▶ ALB Ingress Controller ──생성·타깃 등록──▶ ALB
   앱 Ingress (class: traefik)              ──watch──▶ Traefik

 [트래픽 경로]
   인터넷 ──HTTPS──▶ ALB ──HTTP──▶ 노드 NodePort 32000 ──▶ Traefik ──Host/Path──▶ 앱 Service
```

| 컨트롤러 | IngressClass | 처리하는 Ingress | 하는 일 | 설치 |
|---|---|---|---|---|
| ALB Ingress Controller | `alb` (controller `ncloud.com/alb`) | `traefik/traefik-alb` **1개** | ALB·리스너·타깃 그룹 생성, 노드를 타깃으로 등록 | KVM 기본 포함, 그 외 매니페스트 적용 |
| Traefik | `traefik` (기본 클래스) | 앱 Ingress 전부 | host·path로 앱 Service에 라우팅 | Helm (`terraform-helm` 모듈) |

- Traefik Service는 `type: NodePort`입니다. `type: LoadBalancer`로 두면 NKS가 NLB/NPLB를 따로 만들기 때문에 쓰지 않습니다
- TLS는 ALB에서 종료합니다. ALB → Traefik 구간은 HTTP(NodePort 32000)입니다
- 노드 증감에 따른 타깃 등록·해제는 컨트롤러가 처리합니다. 이 동작은 공식 문서에 명시되어 있지 않으므로 [사후 검증](#사후-검증)에서 직접 확인합니다

> **⚠️ 주의**: ALB는 Kubernetes 리소스로 관리됩니다. ALB Ingress를 삭제하면 ALB도 삭제됩니다. 콘솔·API로 ALB를 직접 수정하면 NCloud 기술 지원 대상에서 제외됩니다.

---

## 전제 조건

| 항목 | 조건 | 확인 방법 |
|---|---|---|
| 클러스터 | KVM 권장 (ALB Ingress Controller 기본 포함). XEN은 직접 설치 | 콘솔 클러스터 상세 |
| kubectl 접근 | `NKSClusterAdminPolicy` 액세스 항목 등록 | `kubectl get nodes` |
| LB 서브넷 | 클러스터 생성 시 지정한 `lb_subnet_id` (private) / `public_lb_subnet_id` | nks 유닛 inputs |
| 인증서 | Certificate Manager에 등록, 인증서 번호 확보 (Terraform 미지원) | [외부 인증서 등록 가이드](https://guide.ncloud-docs.com/docs/certificatemanager-addcertificate) |
| 공인 IP (선택) | ALB 재생성 시에도 IP를 유지하려면 미리 생성한 공인 IP의 인스턴스 번호 | 콘솔 Public IP |

gov 사이트에서 kubectl을 쓸 때는 API Gateway 주소를 지정합니다.

```bash
export NCLOUD_API_GW=https://ncloud.apigw.gov-ntruss.com
```

---

## ALB Ingress Controller 설치

**실행 위치**: 클러스터 (`kube-system` 네임스페이스)

KVM 클러스터에는 기본으로 설치되어 있습니다. 먼저 설치 여부를 확인합니다.

```bash
kubectl -n kube-system get deploy alb-ingress-controller
kubectl get ingressclass alb
# 둘 다 조회되면 설치 생략, IngressClass 정리로 이동
```

없으면 리전에 맞는 매니페스트를 적용합니다.

| 리전 | 매니페스트 |
|---|---|
| gov 수도권 | `https://raw.githubusercontent.com/NaverCloudPlatform/nks-alb-ingress-controller/main/docs/install/gov/install.yaml` |
| gov 남부권 | `https://raw.githubusercontent.com/NaverCloudPlatform/nks-alb-ingress-controller/main/docs/install/gov-krs/install.yaml` |
| 공공 한국 | `https://raw.githubusercontent.com/NaverCloudPlatform/nks-alb-ingress-controller/main/docs/install/pub/install.yaml` |

```bash
kubectl apply -f https://raw.githubusercontent.com/NaverCloudPlatform/nks-alb-ingress-controller/main/docs/install/gov/install.yaml
```

매니페스트가 만드는 리소스(gov 수도권, 0.14.0 기준):

| 리소스 | 이름 | 비고 |
|---|---|---|
| ServiceAccount, ClusterRole, ClusterRoleBinding | `alb-ingress-controller` | |
| IngressClass | `alb` | **`is-default-class: "true"`로 생성됨** → [IngressClass 정리](#ingressclass-정리) 필수 |
| Deployment | `kube-system/alb-ingress-controller` | 이미지 `nks.private-ncr.gov-ntruss.com/alb-ingress-controller:0.14.0`, replicas 1 |

> **⚠️ 주의**: 매니페스트는 `main` 브랜치를 가리키므로 적용 시점에 따라 버전이 바뀝니다. 적용한 파일을 저장소에 함께 보관하고, 다시 적용하면 `alb` IngressClass가 기본 클래스로 되돌아갑니다.

**검증**

```bash
kubectl -n kube-system rollout status deploy/alb-ingress-controller
# 기대값: successfully rolled out

kubectl -n kube-system get deploy alb-ingress-controller -o jsonpath='{.spec.template.spec.containers[0].image}'
# 기대값: ...alb-ingress-controller:0.14.0
```

---

## Traefik 설치

**실행 위치**: Terragrunt helm 유닛 (`terraform-helm` 모듈)

Traefik Service를 NodePort로 열고, ALB 헬스체크용 `/ping`을 web 엔트리포인트에 노출합니다.

```yaml
# charts/traefik.yaml
ports:
  web:
    nodePort: 32000
    forwardedHeaders:
      # ALB 서브넷 대역으로 좁힌다
      trustedIPs:
        - <lb-subnet-cidr>
  websecure:
    expose:
      default: false

service:
  spec:
    type: NodePort

ingressRoute:
  healthcheck:
    enabled: true
    entryPoints: ["web"]

ingressClass:
  name: traefik
```

| 설정 | 이유 |
|---|---|
| `ports.web.nodePort: 32000` | ALB 타깃 그룹 포트를 고정 |
| `forwardedHeaders.trustedIPs` | ALB가 붙인 `X-Forwarded-For`를 신뢰해 클라이언트 IP를 보존 |
| `websecure.expose.default: false` | TLS는 ALB에서 종료하므로 노출하지 않음 |
| `ingressRoute.healthcheck` | `/ping`을 web 엔트리포인트로 노출. 기본값은 외부에 노출되지 않는 `traefik` 엔트리포인트 |
| `ingressClass.name: traefik` | 생략하면 릴리스·네임스페이스로 이름이 정해져 앱 Ingress의 `ingressClassName`과 어긋날 수 있음 |

```hcl
# helm 유닛 inputs
apps = {
  traefik = {
    repository       = "https://traefik.github.io/charts"
    chart            = "traefik"
    version          = "41.6.1"
    namespace        = "traefik"
    create_namespace = true
    values           = [file("charts/traefik.yaml")]
  }
}
```

**검증**

```bash
kubectl -n traefik get svc traefik -o jsonpath='{.spec.type} {.spec.ports[?(@.name=="web")].nodePort}'
# 기대값: NodePort 32000

kubectl -n traefik get ingressroute
# 기대값: healthcheck용 IngressRoute 1개 (entryPoints: web, match: PathPrefix(`/ping`))
```

---

## IngressClass 정리

`alb`(설치 매니페스트)와 `traefik`(차트 기본값 `ingressClass.isDefaultClass: true`)이 **둘 다 기본 클래스로 설치됩니다.** 기본 클래스가 둘이면 클래스를 적지 않은 Ingress가 어느 컨트롤러로 갈지 보장되지 않고, `alb`로 가면 **그 Ingress마다 ALB가 생성됩니다.** `alb`의 기본 클래스 지정을 해제합니다.

```bash
kubectl annotate ingressclass alb ingressclass.kubernetes.io/is-default-class=false --overwrite
```

**검증**

```bash
kubectl get ingressclass \
  -o custom-columns='NAME:.metadata.name,CONTROLLER:.spec.controller,DEFAULT:.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class'
# 기대값:
# NAME      CONTROLLER                      DEFAULT
# alb       ncloud.com/alb                  false
# traefik   traefik.io/ingress-controller   true
```

ALB Ingress Controller 매니페스트를 다시 적용하거나 컨트롤러가 업데이트되면 이 단계를 다시 확인합니다.

---

## ALB Ingress 생성

**실행 위치**: Traefik Service와 같은 네임스페이스

Terragrunt로 관리할 때는 [`terraform-ncloud-nks-alb-ingress`](../modules/ncloud/terraform-ncloud-nks-alb-ingress) 모듈을 씁니다. 이 모듈은 아래 Ingress와 [IngressClass 정리](#ingressclass-정리)를 함께 처리하고, Ingress에 `prevent_destroy`를 걸어 ALB가 같이 삭제되는 것을 막습니다. 이미 수동으로 만든 Ingress는 `terragrunt import kubernetes_ingress_v1.this <namespace>/<name>`으로 가져온 뒤 plan에 교체(replace)가 없는지 확인합니다.

수동으로 적용할 때의 매니페스트:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik-alb
  namespace: traefik
  annotations:
    alb.ingress.kubernetes.io/load-balancer-name: <lb-name>
    alb.ingress.kubernetes.io/network-type: public
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-certificate-no: "<certificate-no>"
    alb.ingress.kubernetes.io/ssl-min-version: TLSV12
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/healthcheck-path: /ping
    alb.ingress.kubernetes.io/public-ip-instance-no: "<public-ip-instance-no>"
    alb.ingress.kubernetes.io/ncloud-load-balancer-retain-public-ip-on-termination: "true"
spec:
  ingressClassName: alb
  defaultBackend:
    service:
      name: traefik
      port:
        number: 80
```

| Annotation | 값 | 비고 |
|---|---|---|
| `load-balancer-name` | 3~30자, 영문·숫자·`-`, 영문으로 시작 | 생성 시에만 적용 |
| `network-type` | `public` / `private` | gov: 값을 바꾸면 LB 재생성 |
| `listen-ports` | HTTP 80, HTTPS 443 | 프로토콜은 HTTP·HTTPS만 지원 |
| `ssl-certificate-no` | Certificate Manager 인증서 번호 | 여러 개는 쉼표 구분. 첫 번째가 기본 인증서 |
| `ssl-redirect` | `443` | HTTP 요청을 HTTPS로 리다이렉트 |
| `healthcheck-path` | `/ping` | 헬스체크 포트 기본값은 타깃 그룹 포트(NodePort 32000) |
| `public-ip-instance-no` | 공인 IP 인스턴스 번호 | 선택. 생략하면 자동 할당 |
| `ncloud-load-balancer-retain-public-ip-on-termination` | `true` | ALB 삭제 시 공인 IP 유지 |

- 모든 요청을 `spec.defaultBackend`(Traefik)로 넘기므로 ALB에는 규칙을 추가하지 않습니다
- 기본값을 그대로 쓰는 annotation(`load-balancer-size: small`, `idle-timeout: 60`, `algorithm-type: round-robin`)은 생략했습니다

**검증**

```bash
kubectl -n traefik get ingress traefik-alb
# 기대값: ADDRESS 열에 ALB 도메인. 생성까지 수 분 소요

kubectl -n traefik describe ingress traefik-alb
# Events에 오류가 없는지 확인
```

---

## 앱 Ingress 작성

**실행 위치**: 앱 네임스페이스

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <app>
  namespace: <app-namespace>
spec:
  ingressClassName: traefik
  rules:
    - host: <app-host>
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <app-service>
                port:
                  number: <port>
```

> **❌ 금지**: `ingressClassName`을 생략하거나 ALB IngressClass를 지정하는 것. 앱 Ingress마다 ALB가 생성됩니다.

- 앱 Service는 ClusterIP로 둡니다. NodePort가 필요한 것은 Traefik뿐입니다
- DNS는 앱 호스트를 ALB 도메인(CNAME) 또는 ALB 공인 IP로 연결합니다

---

## 사후 검증

샘플 매니페스트([examples/nks-alb-traefik](examples/nks-alb-traefik))로 경로 전체를 확인합니다.

| 파일 | 내용 |
|---|---|
| `01-alb-ingress.yaml` | ALB Ingress (`traefik/traefik-alb`). [ALB Ingress 생성](#alb-ingress-생성)과 동일 |
| `02-whoami.yaml` | `ingress-test` 네임스페이스에 whoami 앱 (Deployment, Service, Ingress `class: traefik`). 요청 헤더를 그대로 응답 |

```bash
# <lb-name>, <certificate-no>, <whoami-host> 치환 후
kubectl apply -f docs/examples/nks-alb-traefik/01-alb-ingress.yaml
kubectl apply -f docs/examples/nks-alb-traefik/02-whoami.yaml

kubectl -n ingress-test rollout status deploy/whoami
kubectl -n traefik get ingress traefik-alb
# 기대값: ADDRESS 열에 ALB 주소

# DNS 연결 전에는 Host 헤더로 확인
curl -sk https://<alb-domain>/ -H 'Host: <whoami-host>'
# 기대값: Hostname: whoami-..., X-Forwarded-For: <내 공인 IP>
```

테스트가 끝나면 앱만 지웁니다. `01-alb-ingress.yaml`을 지우면 ALB도 삭제됩니다.

```bash
kubectl delete -f docs/examples/nks-alb-traefik/02-whoami.yaml
```

| 확인 항목 | 명령 / 방법 | 기대 결과 |
|---|---|---|
| 헬스체크 | 콘솔 Load Balancer > 타깃 그룹 > 타깃 상태 | 전체 노드 정상 |
| HTTP → HTTPS | `curl -sI http://<app-host>/` | `301` 또는 `302`, `Location: https://...` |
| 앱 라우팅 | `curl -s https://<app-host>/` | 앱 응답 |
| 클라이언트 IP | 앱 또는 Traefik access log의 `X-Forwarded-For` | 실제 클라이언트 IP |
| **노드 증가 반영** | 워커 노드풀의 노드 수를 1 늘린 뒤 타깃 그룹 확인 | 새 노드가 타깃에 추가됨 |
| **노드 감소 반영** | 노드 수를 원복한 뒤 타깃 그룹 확인 | 제거된 노드가 타깃에서 빠짐 |

> **⚠️ 주의**: 노드 증감 반영은 공식 문서에 명시되어 있지 않습니다. 운영 투입 전에 반드시 위 두 항목을 테스트하고 결과를 이 표에 기록합니다. 반영되지 않으면 이 구성을 쓰지 않습니다.

| 테스트 결과 | 일자 | 확인자 |
|---|---|---|
| 노드 증가 반영 | TBD | TBD |
| 노드 감소 반영 | TBD | TBD |

---

## 운영 규칙

| 규칙 | 이유 |
|---|---|
| ALB Ingress(`traefik/traefik-alb`)는 GitOps로만 변경하고, 자동 삭제(prune)를 끈다 | Ingress가 삭제되면 ALB도 삭제됨 |
| ALB 설정은 annotation으로만 변경한다 | 콘솔 직접 수정은 기술 지원 제외, 컨트롤러가 덮어쓸 수 있음 |
| `load-balancer-name`, `subnet-id`는 생성 후 바꾸지 않는다 | 생성 시에만 적용 |
| gov 사이트에서 `network-type`을 바꾸지 않는다 | LB 재생성 |
| 앱 Ingress는 항상 `ingressClassName: traefik` | ALB 무분별 생성 방지 |
| 파드에 resource requests를 둔다 | Cluster Autoscaler 확장 판단 기준 |

Kubernetes 1.36 이상 KVM 클러스터에서는 `lb.ncloud.naver.com/pause: "true"` annotation을 쓸 수 있습니다. 이 annotation이 있으면 Ingress를 삭제해도 ALB와 타깃 그룹이 유지됩니다. 1.36으로 업그레이드하면 적용을 검토합니다.

---

## 롤백

| 단계 | 문제 | 조치 |
|---|---|---|
| ALB Ingress Controller 설치 | 컨트롤러 기동 실패 | 직접 설치한 경우만 `kubectl delete -f <install.yaml>`. KVM 기본 설치분은 삭제하지 않음 |
| Traefik 설치 | 차트 설치 실패 | helm 유닛에서 `traefik` 항목 제거 후 apply |
| ALB Ingress 생성 | ALB 생성 실패 또는 설정 오류 | `kubectl -n traefik delete ingress traefik-alb`. 공인 IP는 retain 설정으로 유지 |
| 앱 전환 | 앱 라우팅 오류 | DNS를 이전 진입점으로 되돌림 |

---

## 트러블슈팅

| 증상 | 원인 | 조치 |
|---|---|---|
| 앱 Ingress마다 ALB가 생김 | `alb`가 기본 클래스로 남아 있거나 앱 Ingress에 `ingressClassName: alb` 지정 | `ingressClassName: traefik` 지정, [IngressClass 정리](#ingressclass-정리) 재수행 |
| 타깃이 모두 unhealthy | `/ping`이 web 엔트리포인트에 노출되지 않음 | `ingressRoute.healthcheck.entryPoints: ["web"]` 확인, `curl http://<node-ip>:32000/ping` |
| ALB가 생성되지 않음 | annotation 오류, LB 서브넷 미지정 | `kubectl -n traefik describe ingress traefik-alb`의 Events 확인 |
| 앱 로그의 클라이언트 IP가 노드 IP | `forwardedHeaders.trustedIPs`에 ALB 서브넷 대역 누락 | Traefik values 수정 |
| kubectl `Unauthorized` | 액세스 항목 미등록, gov API Gateway 미지정 | `access_entries` 등록, `NCLOUD_API_GW` 확인 |

---

## 검토 이력 및 의사결정

| 안 | 내용 | 결과 | 이유 |
|---|---|---|---|
| **A. ALB Ingress Controller + Traefik** | 컨트롤러가 ALB 생성·타깃 관리 | **채택** | NKS 관리형(KVM 기본 포함), API 키 불필요, 노드 증감 자동 처리 |
| B. Terraform ALB + 고정 노드풀 타깃 | Terragrunt가 ALB 생성, 고정 노드풀 노드를 타깃으로 등록 | 보류 | LB를 Terraform이 소유해야 할 때의 대안. 노드 교체 시 재apply 필요 |
| C. Terraform ALB + 자체 동기화 컨트롤러 | 노드 목록을 타깃 그룹에 동기화하는 컨트롤러 개발 | 탈락 | 개발·운영·API 키 관리 부담. 기존 `ncloud-client`는 제거 처리 부재, 키 커밋 등 문제 |
| 컨트롤러로 기존 ALB 사용 | TargetGroupBinding 방식 | 불가 | 컨트롤러에 기존 LB·타깃 그룹 지정 기능 없음 |
| 여러 Ingress가 ALB 공유 | IngressGroup 방식 | 불가 | 공유 annotation 없음, Ingress당 ALB 1개 |

**참고 문서**

- [ALB Ingress Controller 설정 (gov)](https://guide-gov.ncloud-docs.com/docs/k8s-k8suse-albingress)
- [ALB Ingress Controller 예제](https://guide.ncloud-docs.com/docs/k8s-k8sexamples-albingress)
- [nks-alb-ingress-controller](https://github.com/NaverCloudPlatform/nks-alb-ingress-controller)
- [Cluster Autoscaler (gov)](https://guide-gov.ncloud-docs.com/docs/k8s-k8suse-clusterautoscaler)
