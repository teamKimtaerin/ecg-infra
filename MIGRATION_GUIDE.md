# 🚀 ECG Infrastructure AWS Account Migration Guide

다른 AWS 계정으로 인프라를 마이그레이션하기 위한 완전한 가이드입니다.

## 📋 Overview

이 가이드는 현재 AWS 계정(`084828586938`)에서 새로운 AWS 계정으로 ECG 인프라를 마이그레이션하는 방법을 설명합니다.

## ✅ Prerequisites

- 새로운 AWS 계정에 대한 관리자 권한
- AWS CLI 설정 (새 계정 프로필)
- Terraform >= 1.0
- Docker (컨테이너 이미지 복사용)

## 🔧 Migration Steps

### Step 1: 새 AWS 계정 설정

```bash
# 1. 새 AWS 계정 프로필 설정
aws configure --profile new-account
# Access Key ID, Secret Access Key, Region (us-east-1 권장) 입력

# 2. 프로필 테스트
aws sts get-caller-identity --profile new-account
```

### Step 2: 설정 파일 준비

```bash
# 1. 새 계정용 설정 파일 생성
cp terraform-new-account.tfvars.example terraform-new-account.tfvars

# 2. terraform-new-account.tfvars 파일 편집
# 필수 변경사항:
# - aws_account_id: 새 계정 ID (12자리)
# - aws_region: 원하는 리전
# - 도메인/인증서 설정 (필요한 경우)
```

### Step 3: 컨테이너 이미지 마이그레이션

#### Option A: ECR간 직접 복사 (추천)

```bash
# 1. 원본 계정에서 이미지 pull
export SOURCE_ACCOUNT="084828586938"
export TARGET_ACCOUNT="YOUR_NEW_ACCOUNT_ID"
export REGION="us-east-1"

# 원본 계정 로그인
aws ecr get-login-password --region $REGION --profile original | \
    docker login --username AWS --password-stdin $SOURCE_ACCOUNT.dkr.ecr.$REGION.amazonaws.com

# 이미지 pull
docker pull $SOURCE_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/ecg-project-pipeline-dev-api:latest

# 2. 새 계정에서 ECR 리포지토리 생성
aws ecr create-repository \
    --repository-name ecg-project-pipeline-dev-api \
    --region $REGION \
    --profile new-account

# 3. 새 계정 로그인
aws ecr get-login-password --region $REGION --profile new-account | \
    docker login --username AWS --password-stdin $TARGET_ACCOUNT.dkr.ecr.$REGION.amazonaws.com

# 4. 이미지 태깅 및 푸시
docker tag $SOURCE_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/ecg-project-pipeline-dev-api:latest \
           $TARGET_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/ecg-project-pipeline-dev-api:latest

docker push $TARGET_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/ecg-project-pipeline-dev-api:latest
```

#### Option B: 소스코드에서 재빌드

```bash
# 1. API 소스코드 디렉토리로 이동
cd /path/to/your/api/source

# 2. 새 계정 ECR 로그인
aws ecr get-login-password --region us-east-1 --profile new-account | \
    docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# 3. 새 계정에서 ECR 리포지토리 생성
aws ecr create-repository \
    --repository-name ecg-project-pipeline-dev-api \
    --profile new-account

# 4. 이미지 빌드 및 푸시
docker build --platform linux/amd64 -t YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/ecg-project-pipeline-dev-api:latest .
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/ecg-project-pipeline-dev-api:latest
```

### Step 4: Terraform 초기화 및 배포

```bash
# 1. Terraform 초기화 (새 계정용 백엔드)
AWS_PROFILE=new-account terraform init

# 2. 계획 확인
AWS_PROFILE=new-account terraform plan -var-file="terraform-new-account.tfvars"

# 3. 인프라 배포
AWS_PROFILE=new-account terraform apply -var-file="terraform-new-account.tfvars"
```

### Step 5: GPU 인스턴스 설정 (선택사항)

> 🎵 **오디오 분석 워크로드가 있는 경우**: 기존 `ecg-audio-production` 인스턴스를 새 계정으로 마이그레이션할 수 있습니다.

#### 5.1 키 페어 생성

```bash
# 1. 새 계정에서 키 페어 생성
aws ec2 create-key-pair \
    --key-name ecg-audio-key \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/ecg-audio-key.pem \
    --profile new-account

# 2. 키 파일 권한 설정
chmod 400 ~/.ssh/ecg-audio-key.pem
```

#### 5.2 terraform-new-account.tfvars 업데이트

```bash
# GPU 인스턴스 활성화
gpu_instance_enabled = true
gpu_instance_type = "g4dn.2xlarge"  # 또는 g4dn.xlarge (비용 절약)
gpu_instance_volume_size = 100
gpu_instance_key_name = "ecg-audio-key"
```

#### 5.3 GPU 인스턴스 배포 및 설정

```bash
# 1. Terraform apply (GPU 인스턴스 포함)
AWS_PROFILE=new-account terraform apply -var-file="terraform-new-account.tfvars"

# 2. 인스턴스 정보 확인
AWS_PROFILE=new-account terraform output gpu_instance_public_ip
AWS_PROFILE=new-account terraform output gpu_instance_ssh_command

# 3. SSH 접속 테스트
ssh -i ~/.ssh/ecg-audio-key.pem ubuntu@INSTANCE_PUBLIC_IP

# 4. 인스턴스 상태 확인
nvidia-smi  # GPU 확인
df -h       # 디스크 사용량 확인
htop        # CPU/메모리 사용량 확인
```

#### 5.4 애플리케이션 코드 배포

```bash
# 기존 인스턴스에서 코드 백업 (원본 계정에서)
scp -i ~/.ssh/original-key.pem -r ubuntu@ORIGINAL_IP:/opt/audio-production ./audio-production-backup

# 새 인스턴스로 코드 복사 (새 계정에서)
scp -i ~/.ssh/ecg-audio-key.pem -r ./audio-production-backup/* ubuntu@NEW_IP:/opt/audio-production/

# 서비스 시작
sudo systemctl start audio-production
sudo systemctl status audio-production
```

#### 5.5 비용 최적화 팁

```bash
# 사용하지 않을 때 인스턴스 중지 (EBS 볼륨 비용만 발생)
aws ec2 stop-instances --instance-ids INSTANCE_ID --profile new-account

# 필요할 때 다시 시작
aws ec2 start-instances --instance-ids INSTANCE_ID --profile new-account

# 완전히 삭제 (terraform으로 관리)
# terraform-new-account.tfvars에서 gpu_instance_enabled = false로 설정 후
AWS_PROFILE=new-account terraform apply -var-file="terraform-new-account.tfvars"
```

## 🌐 Domain Configuration (선택사항)

새 계정에서 커스텀 도메인을 사용하려면:

### Step 1: Route53 설정

```bash
# 1. 새 계정에서 호스팅 존 생성 (도메인이 있는 경우)
aws route53 create-hosted-zone \
    --name your-domain.com \
    --caller-reference $(date +%s) \
    --profile new-account

# 2. NS 레코드를 도메인 등록업체에 설정
aws route53 list-hosted-zones --profile new-account
```

### Step 2: SSL 인증서 생성 (선택사항)

> ⚠️ **중요**: 커스텀 도메인이 없으면 이 단계를 건너뛰세요. CloudFront 기본 도메인을 사용할 수 있습니다.

커스텀 도메인을 사용하려면:

1. **AWS Console에서 ACM 인증서 발급**
   - AWS Console → Certificate Manager (ACM)
   - **반드시 us-east-1 리전**에서 인증서 요청
   - DNS 검증 방법 선택
   - 도메인 소유권 검증 완료

2. **또는 CLI로 인증서 요청**
   ```bash
   aws acm request-certificate \
       --domain-name your-domain.com \
       --subject-alternative-names www.your-domain.com \
       --validation-method DNS \
       --region us-east-1 \
       --profile new-account
   ```

### Step 3: terraform-new-account.tfvars 업데이트

```bash
# 커스텀 도메인 사용시만 설정
cloudfront_domain_aliases = ["your-domain.com", "www.your-domain.com"]
cloudfront_certificate_arn = "arn:aws:acm:us-east-1:YOUR_ACCOUNT:certificate/YOUR_CERT_ID"

# 커스텀 도메인 없으면 기본값 유지 (CloudFront 기본 도메인 사용)
# cloudfront_domain_aliases = []
# cloudfront_certificate_arn = null
```

## 🗂️ File Structure

마이그레이션 후 파일 구조:

```
ecg-infra/
├── terraform.tfvars                    # 원본 계정 설정 (보존)
├── terraform-new-account.tfvars        # 새 계정 설정
├── terraform-new-account.tfvars.example # 템플릿 파일
├── MIGRATION_GUIDE.md                  # 이 파일
└── ... (기타 Terraform 파일들)
```

## 🔍 Verification

배포 완료 후 확인사항:

```bash
# 1. CloudFront 배포 상태 확인
aws cloudfront list-distributions --profile new-account

# 2. ECS 서비스 상태 확인
aws ecs list-services --cluster ecg-project-pipeline-dev-cluster --profile new-account

# 3. RDS 인스턴스 확인
aws rds describe-db-instances --profile new-account

# 4. API 엔드포인트 테스트
curl https://YOUR_CLOUDFRONT_DOMAIN/health
# 또는
curl https://YOUR_ALB_DOMAIN/health
```

## ⚠️ Important Notes

### 계정 종속 리소스들
- **ECR 리포지토리**: 새 계정에 재생성 필요
- **ACM 인증서**: 커스텀 도메인 사용시 새 계정 Console에서 수동 발급 필요
- **Route53 호스팅 존**: 도메인 사용시 새 계정에 생성 필요

### 비용 고려사항
- **NAT 게이트웨이**: 현재 구성에서 제거됨 (비용 절약)
- **ElastiCache**: 비용 최적화를 위해 제거됨 (추가 비용 절약)
- **RDS**: 새 계정에서 신규 생성됨
- **CloudFront**: 글로벌 서비스로 추가 비용 발생 가능
- **GPU 인스턴스**: 선택사항이며 높은 비용 ($18-30/일) - 사용하지 않을 때 중지 권장

### 보안 고려사항
- **IAM 역할**: 새 계정에서 자동 생성됨
- **Security Groups**: 동일한 규칙으로 새 계정에 생성됨
- **데이터베이스 비밀번호**: 새로운 임의 값으로 생성됨

## 🆘 Troubleshooting

### 일반적인 문제들

1. **ECR 권한 오류**
   ```bash
   # ECR 정책 확인
   aws ecr get-repository-policy --repository-name ecg-project-pipeline-dev-api --profile new-account
   ```

2. **Certificate ARN 찾기**
   ```bash
   # ACM 인증서 목록 확인
   aws acm list-certificates --region us-east-1 --profile new-account
   ```

3. **Terraform 백엔드 설정**
   ```bash
   # S3 백엔드 사용시 새 계정에서 버킷 생성 필요
   aws s3 mb s3://terraform-state-new-account --profile new-account
   ```

## 📞 Support

문제가 발생하면 다음을 확인하세요:
1. AWS CLI 프로필 설정 확인
2. 필수 AWS 권한 확인
3. 리전 설정 일치 확인
4. terraform-new-account.tfvars 파일 내용 검토

---

✅ 이 가이드를 따라하시면 성공적으로 새 AWS 계정으로 인프라를 마이그레이션할 수 있습니다!