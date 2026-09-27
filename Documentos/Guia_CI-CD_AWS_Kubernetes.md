# 🚀 Guia de Implantação e Deploy em Produção (AWS EKS + PostgreSQL)

## 📋 Sumário
1. [Arquitetura de Produção na AWS](#1-arquitetura-de-produção-na-aws)
2. [Pré-requisitos e Ferramentas](#2-pré-requisitos-e-ferramentas)
3. [Provisionamento da Infraestrutura (ECR e Cluster EKS)](#3-provisionamento-da-infraestrutura-ecr-e-cluster-eks)
4. [Instalação do Driver de Armazenamento Persistente (EBS CSI)](#4-instalação-do-driver-de-armazenamento-persistente-ebs-csi)
5. [Manifestos Kubernetes: ConfigMaps, Secrets e PostgreSQL](#5-manifestos-kubernetes-configmaps-secrets-e-postgresql)
6. [Deploy das Aplicações (Backend FastAPI e Frontend Nginx)](#6-deploy-das-aplicações-backend-fastapi-e-frontend-nginx)
7. [Exposição Pública com AWS ALB Ingress Controller e SSL/TLS](#7-exposição-pública-com-aws-alb-ingress-controller-e-ssltls)
8. [Estratégia de Backup do Banco de Dados (Snapshots e pg_dump)](#8-estratégia-de-backup-do-banco-de-dados-snapshots-e-pg_dump)

---

## 1. Arquitetura de Produção na AWS

```text
                               ┌─────────────────────────────────────────┐
                               │        Usuário / Navegador Web          │
                               └────────────────────┬────────────────────┘
                                                    │ HTTPS (Porta 443)
                                                    ▼
                               ┌─────────────────────────────────────────┐
                               │   AWS Application Load Balancer (ALB)   │
                               └────────────────────┬────────────────────┘
                                                    │
                                                    ▼
                               ┌─────────────────────────────────────────┐
                               │         Ingress Controller Nginx        │
                               └──────────┬──────────────────┬───────────┘
                                          │ /                │ /api
                                          ▼                  ▼
┌─────────────────────────────────────────┴────┐   ┌─────────┴───────────────────────────────────┐
│ Pods Frontend (Nginx Estático)               │   │ Pods Backend (FastAPI / Uvicorn)            │
│ Réplicas: 2                                  │   │ Réplicas: 2                                 │
└──────────────────────────────────────────────┘   └─────────┬───────────────────────────────────┘
                                                             │ ConfigMap & Secret (DATABASE_URL)
                                                             ▼
                                                   ┌─────────────────────────────────────────────┐
                                                   │ Pod PostgreSQL (StatefulSet)                │
                                                   │ Volume: AWS EBS gp3 (PVC 20GB)              │
                                                   └─────────────────────────────────────────────┘
```

---

## 2. Pré-requisitos e Ferramentas

Instale as seguintes ferramentas na sua máquina local ou estação de deploy:
* **AWS CLI v2** configurada com credenciais de Administrador (`aws configure`).
* **eksctl** (CLI oficial para gerenciamento de clusters AWS EKS).
* **kubectl** (CLI de controle do Kubernetes).
* **Helm v3** (Gerenciador de pacotes Kubernetes).

---

## 3. Provisionamento da Infraestrutura (ECR e Cluster EKS)

### 3.1. Criar os Repositórios de Imagens no AWS ECR
```bash
# Repositório para a API FastAPI (Backend)
aws ecr create-repository --repository-name sistema-juridico-backend --region sa-east-1

# Repositório para o Nginx (Frontend)
aws ecr create-repository --repository-name sistema-juridico-frontend --region sa-east-1
```

### 3.2. Criar o Cluster AWS EKS com `eksctl`
Crie um arquivo chamado `eks-cluster.yaml`:
```yaml
apiVersion: eksctl.io/v1alpha1
kind: ClusterConfig

metadata:
  name: cluster-sistema-juridico
  region: sa-east-1
  version: "1.29"

nodeGroups:
  - name: ng-advocacia-workers
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 2
    maxSize: 4
    volumeSize: 30
    volumeType: gp3
    privateNetworking: true
    iam:
      withAddonPolicies:
        ebs: true
        albIngress: true
```

Execute o provisionamento no terminal:
```bash
eksctl create cluster -f eks-cluster.yaml
aws eks update-kubeconfig --region sa-east-1 --name cluster-sistema-juridico
```

---

## 4. Instalação do Driver de Armazenamento Persistente (EBS CSI)

Para que o PostgreSQL consiga gravar dados em um disco persistente AWS EBS na nuvem:

```bash
# Adiciona a role IAM do EBS CSI
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster cluster-sistema-juridico \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --role-only \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

# Instala o addon oficial no cluster
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster cluster-sistema-juridico \
  --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole \
  --force
```

---

## 5. Manifestos Kubernetes: ConfigMaps, Secrets e PostgreSQL

### 5.1. `01-configmap.yaml` (Parâmetros Não Sensíveis)
O **ConfigMap** armazena variáveis de ambiente que não contêm senhas ou chaves privadas:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sistema-juridico-config
  namespace: default
data:
  DB_HOST: "sistema-juridico-db"
  DB_PORT: "5432"
  DB_NAME: "sistema_juridico"
  POSTGRES_USER: "postgres"
  ENVIRONMENT: "production"
  LOG_LEVEL: "info"
```

### 5.2. `02-secrets.yaml` (Credenciais e Chaves Criptografadas)
O **Secret** protege dados sensíveis como senhas do banco de dados e a chave de assinatura dos tokens JWT:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sistema-juridico-secrets
  namespace: default
type: Opaque
stringData:
  POSTGRES_PASSWORD: "SenhaProdSegura_Postgres_2026!#%"
  SECRET_KEY: "chave_jwt_super_secreta_producao_escritorio_advocacia_univesp_2026"
  DATABASE_URL: "postgresql://postgres:SenhaProdSegura_Postgres_2026!#%@sistema-juridico-db:5432/sistema_juridico"
```

### 5.3. `03-postgres-aws.yaml` (StorageClass gp3 + PVC + StatefulSet)
Manifesto para o PostgreSQL relacional com volume dinâmico de 20GB no AWS EBS:

```yaml
# StorageClass para alocação dinâmica no AWS EBS gp3
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
---
# PVC (Persistent Volume Claim)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-gp3-sc
  resources:
    requests:
      storage: 20Gi
---
# Deployment / StatefulSet do PostgreSQL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sistema-juridico-db
  labels:
    app: sistema-juridico-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sistema-juridico-db
  template:
    metadata:
      labels:
        app: sistema-juridico-db
    spec:
      containers:
        - name: postgres
          image: postgres:15-alpine
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_USER
              valueFrom:
                configMapKeyRef:
                  name: sistema-juridico-config
                  key: POSTGRES_USER
            - name: POSTGRES_DB
              valueFrom:
                configMapKeyRef:
                  name: sistema-juridico-config
                  key: DB_NAME
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: sistema-juridico-secrets
                  key: POSTGRES_PASSWORD
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1000m"
              memory: "1Gi"
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
                - -d
                - sistema_juridico
            initialDelaySeconds: 10
            periodSeconds: 5
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: postgres-pvc
---
# Serviço Interno do Banco de Dados
apiVersion: v1
kind: Service
metadata:
  name: sistema-juridico-db
spec:
  selector:
    app: sistema-juridico-db
  ports:
    - port: 5432
      targetPort: 5432
  type: ClusterIP
```

---

## 6. Deploy das Aplicações (Backend FastAPI e Frontend Nginx)

### 6.1. `04-backend-aws.yaml` (API FastAPI)
Deployment da API conectando às variáveis injetadas via **ConfigMap** e **Secret**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sistema-juridico-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sistema-juridico-backend
  template:
    metadata:
      labels:
        app: sistema-juridico-backend
    spec:
      containers:
        - name: backend
          image: ACCOUNT_ID.dkr.ecr.sa-east-1.amazonaws.com/sistema-juridico-backend:latest
          ports:
            - containerPort: 8000
          envFrom:
            - configMapRef:
                name: sistema-juridico-config
            - secretRef:
                name: sistema-juridico-secrets
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          livenessProbe:
            httpGet:
              path: /docs
              port: 8000
            initialDelaySeconds: 15
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: sistema-juridico-backend
  ports:
    - port: 8000
      targetPort: 8000
  type: ClusterIP
```

### 6.2. `05-frontend-aws.yaml` (Nginx Estático)
Deployment da interface web acessível e responsiva:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sistema-juridico-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sistema-juridico-frontend
  template:
    metadata:
      labels:
        app: sistema-juridico-frontend
    spec:
      containers:
        - name: frontend
          image: ACCOUNT_ID.dkr.ecr.sa-east-1.amazonaws.com/sistema-juridico-frontend:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "200m"
              memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: sistema-juridico-frontend
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

---

## 7. Exposição Pública com AWS ALB Ingress Controller e SSL/TLS

### 7.1. `06-ingress-alb.yaml`
Configuração do ponto de entrada público com suporte a HTTPS e redirecionamento de rotas:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sistema-juridico-ingress
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:sa-east-1:ACCOUNT_ID:certificate/SEU_CERTIFICADO_ACM
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
    - host: sistema.suaempresa.com.br
      http:
        paths:
          # Requisições de API vão para o Backend FastAPI
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: backend-service
                port:
                  number: 8000
          # Todo o tráfego estático vai para o Frontend Nginx
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
```

---

## 8. Estratégia de Backup do Banco de Dados (Snapshots e pg_dump)

Para garantir o **Disaster Recovery** e a conformidade da segurança da informação no escritório de advocacia:

### Backup Automatizado via CronJob Kubernetes (`pg_dump` para o Amazon S3)
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup-s3
spec:
  schedule: "0 2 * * *" # Todos os dias às 02:00 da manhã
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: postgres-backup
              image: amazon/aws-cli:latest
              command:
                - /bin/sh
                - -c
                - |
                  yum install -y postgresql
                  export PGPASSWORD=$POSTGRES_PASSWORD
                  pg_dump -h sistema-juridico-db -U postgres sistema_juridico | gzip > /tmp/backup-$(date +%Y%m%d%H%M).sql.gz
                  aws s3 cp /tmp/backup-*.sql.gz s3://seu-bucket-backups-escritorio/
              envFrom:
                - secretRef:
                    name: sistema-juridico-secrets
          restartPolicy: OnFailure
```
