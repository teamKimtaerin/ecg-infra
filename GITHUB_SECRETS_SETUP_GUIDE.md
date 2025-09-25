# 🔐 GitHub Secrets 설정 가이드 - 새 AWS 계정 마이그레이션

새 AWS 계정으로 마이그레이션할 때 필요한 GitHub Secrets 설정 방법입니다.

## 📋 개요

CI/CD 파이프라인이 새 AWS 계정에서 정상 작동하려면 다음 GitHub Secrets을 업데이트해야 합니다:

### 🚨 **반드시 수정해야 하는 계정별 Secrets**

## 1. 🎨 **Frontend Repository Secrets**

### Repository: `ecg-frontend`

| Secret Name | 설명 | 예시 값 | 가져오는 방법 |
|-------------|------|---------|---------------|
| `S3_BUCKET_NAME` | Frontend 정적 파일용 S3 버킷명 | `new-account-frontend-bucket` | `terraform output s3_frontend_bucket` |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront 배포 ID | `E1A2B3C4D5E6F7` | `terraform output cloudfront_distribution_id` |
| `CLOUDFRONT_DOMAIN` | CloudFront 도메인 | `d123abc.cloudfront.net` | `terraform output cloudfront_domain_name` |

### ✅ **유지해도 되는 Secrets (계정 무관)**
- `NEXT_PUBLIC_*` 환경변수들
- `AWS_BEDROCK_*` API 키들

## 2. ⚙️ **Backend Repository Secrets**

### Repository: `ecg-backend`

#### 🚨 **새로 추가 필요한 ECS 관련 Secrets:**

| Secret Name | 설명 | 값 가져오는 방법 |
|-------------|------|------------------|
| `ECR_REPOSITORY_NAME` | ECR 리포지토리 이름 | `terraform output ecr_api_repository_url`에서 마지막 부분 |
| `ECS_SERVICE_NAME` | ECS 서비스 이름 | `terraform output ecs_service_name` |
| `ECS_TASK_DEFINITION_NAME` | ECS 태스크 정의 이름 | `{project_name}-{environment}-api` |
| `ECS_CLUSTER_NAME` | ECS 클러스터 이름 | `terraform output ecs_cluster_name` |

#### 📡 **업데이트 필요한 인프라 관련 Secrets:**

| Secret Name | 설명 | 값 가져오는 방법 |
|-------------|------|------------------|
| `S3_BUCKET_NAME` | 백엔드에서 사용하는 S3 버킷 | `terraform output s3_video_storage_bucket` |
| `DB_HOST` | RDS 엔드포인트 | `terraform output rds_endpoint` |
| `DATABASE_URL` | 전체 DB 연결 URL | `terraform output database_url` (sensitive) |

#### ✅ **공통 Secrets (두 계정 모두 동일하게 설정)**

| Secret Name | 설명 |
|-------------|------|
| `AWS_ACCESS_KEY_ID` | 새 계정의 AWS Access Key |
| `AWS_SECRET_ACCESS_KEY` | 새 계정의 AWS Secret Key |
| `AWS_REGION` | AWS 리전 (보통 동일) |

## 🚀 **설정 단계별 가이드**

### Step 1: 테라폼 output 값 확인

새 계정에서 terraform apply 후 다음 명령어들로 값을 확인:

```bash
# 새 계정에서 실행
cd /path/to/ecg-infra

# Frontend 관련 값들
terraform output s3_frontend_bucket
terraform output cloudfront_distribution_id
terraform output cloudfront_domain_name

# Backend 관련 값들
terraform output ecr_api_repository_url
terraform output ecs_cluster_name
terraform output ecs_service_name
terraform output s3_video_storage_bucket
terraform output rds_endpoint

# Sensitive 값 (주의!)
terraform output database_url
```

### Step 2: GitHub Secrets 업데이트

각 리포지토리에서:

1. **Settings** → **Secrets and variables** → **Actions**
2. 기존 Secrets **Update** 또는 새로 **New repository secret** 생성

### Step 3: 수정된 CD 파일 적용 (Backend만)

`ecg-backend/.github/workflows/cd.yml` 파일을 다음과 같이 수정:

```yaml
env:
  AWS_REGION: us-east-1
  # 계정별 변수들을 GitHub Secrets에서 가져오기
  ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY_NAME }}
  ECS_SERVICE: ${{ secrets.ECS_SERVICE_NAME }}
  ECS_TASK_DEFINITION: ${{ secrets.ECS_TASK_DEFINITION_NAME }}
  ECS_CLUSTER: ${{ secrets.ECS_CLUSTER_NAME }}
```

## 🔍 **Secrets 값 예시**

### 기존 계정 (084828586938):
```
ECR_REPOSITORY_NAME = "ecg-project-pipeline-dev-api"
ECS_SERVICE_NAME = "ecg-project-pipeline-dev-api-service"
ECS_TASK_DEFINITION_NAME = "ecg-project-pipeline-dev-api"
ECS_CLUSTER_NAME = "ecg-project-pipeline-dev-cluster"
S3_BUCKET_NAME = "ecg-project-pipeline-dev-video-storage-np9digv7"
```

### 새 계정 (987654321098):
```
ECR_REPOSITORY_NAME = "ecg-video-pipeline-dev-api"
ECS_SERVICE_NAME = "ecg-video-pipeline-dev-api-service"
ECS_TASK_DEFINITION_NAME = "ecg-video-pipeline-dev-api"
ECS_CLUSTER_NAME = "ecg-video-pipeline-dev-cluster"
S3_BUCKET_NAME = "ecg-video-pipeline-dev-video-storage-ab1cde23"
```

## ⚡ **빠른 설정 체크리스트**

### Frontend Repository:
- [ ] `S3_BUCKET_NAME` 업데이트
- [ ] `CLOUDFRONT_DISTRIBUTION_ID` 업데이트
- [ ] `CLOUDFRONT_DOMAIN` 업데이트
- [ ] `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` 업데이트

### Backend Repository:
- [ ] `ECR_REPOSITORY_NAME` 추가/업데이트
- [ ] `ECS_SERVICE_NAME` 추가/업데이트
- [ ] `ECS_TASK_DEFINITION_NAME` 추가/업데이트
- [ ] `ECS_CLUSTER_NAME` 추가/업데이트
- [ ] `S3_BUCKET_NAME` 업데이트
- [ ] `DB_HOST` 업데이트
- [ ] `DATABASE_URL` 업데이트
- [ ] `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` 업데이트
- [ ] `cd.yml` 파일 수정 적용

## 🔒 **보안 주의사항**

1. **Database URL**은 민감한 정보이므로 안전하게 복사
2. **AWS Keys**는 새 계정의 것으로 교체
3. **Terraform output**에서 값을 복사할 때 정확히 복사
4. 설정 후 **테스트 배포**로 검증 권장

## 🆘 **트러블슈팅**

### 문제: ECR 리포지토리를 찾을 수 없음
**해결:** `ECR_REPOSITORY_NAME`이 올바른지 확인. 전체 URI가 아닌 리포지토리 이름만 입력.

### 문제: ECS 서비스 업데이트 실패
**해결:** ECS 관련 Secrets (`ECS_CLUSTER_NAME`, `ECS_SERVICE_NAME` 등)이 terraform output과 일치하는지 확인.

### 문제: S3 접근 권한 오류
**해결:** 새 계정의 IAM 권한과 S3 버킷 이름이 올바른지 확인.

이제 새 AWS 계정에서 CI/CD가 정상 작동할 것입니다! 🎉