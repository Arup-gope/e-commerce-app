# 🛒 EasyShop – Automated E-Commerce Platform on AWS EKS

**EasyShop** is a full-stack, cloud-native e-commerce application built and deployed using an **end-to-end DevSecOps pipeline** on **AWS EKS**.

The project demonstrates how to design, secure, deploy, and operate a production-grade containerized application using **modern DevOps and GitOps practices**. Cloud infrastructure is provisioned automatically using **Terraform**, while **Jenkins CI** orchestrates the complete application lifecycle including code checkout, Docker image builds, testing, and security scanning.

To enable **GitOps-based continuous deployment**, **Argo CD** and **Helm** are used to synchronize Kubernetes manifest changes directly from GitHub to the EKS cluster. The platform also includes **full-stack observability**, achieved through **Prometheus** and **Grafana**, providing real-time visibility into cluster health and application performance.


<p align="center">
  <img width="1872" height="952" alt="Website_Home_Page" src="https://github.com/user-attachments/assets/fff205e2-7d52-443d-a33c-0afcd913147c" />
  <br/>
  <em>Figure 1: EasyShop online shop deployed on AWS EKS</em>
</p>

---


### 🔑 Key Capabilities

- Automated infrastructure provisioning on AWS using Terraform  
- End-to-end CI pipeline with Jenkins  
- Secure container builds with integrated security scanning  
- GitOps-driven deployments using Argo CD and Helm  
- Scalable Kubernetes workloads running on Amazon EKS  
- Real-time monitoring and metrics with Prometheus & Grafana  

---


## 🏗 System Architecture
1. **Infrastructure as Code:** Built the cloud infrastructure for the application on **Amazon EKS** using **Terraform** for automated provisioning.
2. **Continuous Integration:** Developed a **Jenkins** pipeline to automate code retrieval, **Docker** builds, and **Trivy** security scanning.
3. **GitOps Deployment:** Adopted **GitOps** principles with **ArgoCD** and **Helm** to enable automated synchronization of manifest changes from GitHub to the cluster.
4. **Monitoring:** Established full-stack observability by deploying **Prometheus and Grafana** to monitor real-time cluster and application performance.


## 🏗️ Infrastructure Provisioning with Terraform

The cloud infrastructure for **EasyShop** is fully provisioned using **Terraform**, enabling a consistent, repeatable, and automated deployment on **AWS**.

Terraform is used to define the entire infrastructure as code (IaC), eliminating manual setup and ensuring the environment can be recreated reliably at any time.

### 🔧 What Terraform Provisions

Terraform provisions and configures the following AWS resources:

- **Amazon EKS Cluster**
  - Managed Kubernetes control plane
  - Worker node groups for application workloads

- **Networking**
  - Custom VPC
  - Public and private subnets
  - Route tables and Internet Gateway

- **Security & Access**
  - IAM roles and policies for EKS, worker nodes, and EC2
  - Security groups with controlled inbound and outbound access

- **Jenkins CI Server**
  - EC2 instance provisioned for Jenkins
  - Security group allowing access to Jenkins UI
  - IAM role to interact with AWS, EKS, and ECR/Docker Hub

This approach ensures that both **CI infrastructure (Jenkins)** and **application runtime infrastructure (EKS)** are managed centrally through Terraform.

### 🚀 Key Benefits

- **Fully automated infrastructure provisioning** using `terraform apply`
- **Infrastructure consistency** across deployments
- **Scalable Kubernetes environment** on AWS EKS
- **Separation of concerns** between CI (Jenkins) and runtime (EKS)
- **Improved security** through IAM role-based access control

### 📤 Terraform Outputs

Terraform outputs expose critical infrastructure information such as:

- Jenkins EC2 public IP / DNS  
- EKS cluster name and endpoint  
- AWS region and VPC ID  

These outputs are later consumed by **Jenkins**, **kubectl**, and **Argo CD** to automate cluster access and deployments.

<p align="center">
  <img width="1115" height="297" alt="Terraform_Output" src="https://github.com/user-attachments/assets/69e1dda5-674d-438f-b043-85529bd01eb0" />
  <br/>
  <em>Figure 2: Terraform output showing EKS cluster and Jenkins EC2 provisioning 
</em>
</p>

## ⚙️ Jenkins CI Pipeline

The **Jenkins CI pipeline** automates the entire lifecycle of the **EasyShop** application, from code retrieval to deployment-ready artifacts.

This pipeline is implemented using a **Jenkins Shared Library**, which encapsulates all reusable functions for building, testing, scanning, and deploying the application.

### 🔄 Pipeline Workflow

1. **Code Checkout**
   - Pulls the latest application code from the Git repository.
   - Supports branch selection to enable feature or mainline builds.

2. **Docker Image Build**
   - Builds Docker images for:
     - Main application (`easyshop-app`)
     - Migration jobs (`easyshop-migration`)
   - Uses `BUILD_NUMBER` as the image tag for traceability.

3. **Unit Testing**
   - Runs automated tests to ensure application correctness before deployment.

4. **Security Scanning**
   - Uses **Trivy** to scan Docker images for vulnerabilities.
   - Any critical findings fail the build, enforcing DevSecOps principles.

5. **Docker Image Push**
   - Pushes successfully built images to **Docker Hub**.
   - Credentials are securely stored in Jenkins.

6. **Kubernetes Manifest Update**
   - Updates deployment YAML files with new image tags.
   - Ensures ingress host is set correctly.
   - Commits and pushes changes to the **Kubernetes manifests Git repository**, enabling GitOps.

---

### 📤 Jenkins Outputs

<p align="center">
<img width="1297" height="775" alt="Jenkins_Console_Output" src="https://github.com/user-attachments/assets/613dd68a-76c9-4766-840d-1278a5be8a57" />


  <br/>
  <em>Figure 3: Jenkins console output showing pipeline execution</em>
</p>

<p align="center">

<img width="1217" height="758" alt="Automatic_Pushed_in_DockerHub_By_Jenkins" src="https://github.com/user-attachments/assets/7a35d4e0-4505-40b4-a687-d4ec6a8efbd6" />

 
  <br/>
  <em>Figure 4: Docker Hub registry showing updated EasyShop images</em>
</p>

<p align="center">

<img width="1398" height="901" alt="Automatic_Update_By_Jenkins" src="https://github.com/user-attachments/assets/c3d9ad7f-39fa-492f-a2f6-15aafc5e78c8" />

  
  <br/>
  <em>Figure 5: Git repository with updated Kubernetes manifest files</em>
</p>

## 🔄 GitOps Deployment with Argo CD

**Argo CD** is used to implement a **GitOps workflow** for the **EasyShop** application.  
Instead of Jenkins directly applying Kubernetes manifests, Argo CD continuously monitors the Git repository containing deployment manifests and automatically synchronizes them to the Kubernetes cluster.

### 🧭 Workflow Overview

1. **Monitor Git Repository**
   - Watches the repository where Jenkins commits updated Kubernetes manifests.
   - Detects changes in image tags, ingress configurations, or any other resource updates.

2. **Automatic Synchronization**
   - Applies changes automatically to the **EKS cluster**.
   - Ensures the cluster state always matches the desired state defined in Git.

3. **Status Monitoring**
   - Argo CD UI shows the health of applications and resources.
   - Supports rollbacks and visual comparison of current vs. desired states.

4. **Seamless GitOps Integration**
   - Jenkins updates manifests → Argo CD detects changes → Cluster is updated automatically.
   - No need for manual `kubectl apply` commands.

---

### 📤 Argo CD Outputs

<p align="center">
  
  <img width="1883" height="928" alt="ArgoCD_Page" src="https://github.com/user-attachments/assets/f98a4ada-2394-4a03-a4f2-c124931ada51" />

  <br/>
  <em>Figure 5: Argo CD dashboard showing EasyShop application in sync and healthy state</em>
</p>

# 📊 Monitoring with Prometheus & Grafana

To ensure **full observability** of the **EasyShop** Kubernetes cluster and application, we deployed **Prometheus** and **Grafana** using **Helm charts**.

---

## 🔹 Prometheus

**Prometheus** collects real-time metrics from the Kubernetes cluster, including nodes, pods, and application-level data.

### Features

- Monitors cluster CPU and memory usage  
- Tracks pod and container metrics  
- Monitors Kubernetes API server and Kubelet health  
- Stores time-series metrics for dashboards and alerts  

### Installation (Helm)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus

```
<p align="center"> 
  <img width="1857" height="952" alt="Running_Prometheus_Metrics" src="https://github.com/user-attachments/assets/de1e97ad-ef7d-4340-9857-e27347a81c15" />

  <br/> <em>Figure 6: Prometheus dashboard showing cluster and application metrics</em> </p>

## 🔹 Grafana Monitoring

**Grafana** is used to **visualize metrics collected by Prometheus**. It provides **dashboards for cluster and application monitoring**.

### Installation (Helm)

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana

  ```

1️⃣ Grafana Home Dashboard
<p align="center"> 
  <img width="1885" height="947" alt="Grafana_Dashboard_1" src="https://github.com/user-attachments/assets/77657efd-3bd3-441b-99f3-0e81b3585263" />

  <br/> <em>Figure 7: Grafana home dashboard</em> </p>
2️⃣ API Server Monitoring Dashboard
<p align="center"> 
  <img width="1887" height="920" alt="Grafana_API_Server_Monitor" src="https://github.com/user-attachments/assets/630eefea-40eb-409e-907b-4f2e8611b7ee" />

  <br/> <em>Figure 8: Grafana dashboard monitoring Kubernetes API server metrics</em> </p>
3️⃣ Cluster Resources Monitoring Dashboard
<p align="center"> 
  <img width="1892" height="931" alt="Grafana_Cluster_Rescources_Monitor" src="https://github.com/user-attachments/assets/84799c40-32ad-4983-9ada-f21b82578e0e" />

  <br/> <em>Figure 9: Grafana dashboard showing CPU, memory, and pod metrics for the cluster</em> </p>

  
4️⃣ Kubelet Monitoring Dashboard
<p align="center"> 
  <img width="1890" height="972" alt="Grafana_Kubelet_Monitor" src="https://github.com/user-attachments/assets/25562f3b-80d7-4cfb-8fc3-09c8ed724f09" />

  <br/> <em>Figure 10: Grafana dashboard monitoring Kubelet metrics per node</em> </p>

  # 🎉 Final Result: Running EasyShop Application

After deploying the application on **AWS EKS** with **Terraform, Jenkins CI, ArgoCD, Prometheus, and Grafana**, the EasyShop e-commerce platform is fully functional.  

The following screenshots show the key features of the running application.

---

## 1️⃣ Account Creation

<p align="center">
  <img width="1887" height="972" alt="New_Account_Create" src="https://github.com/user-attachments/assets/3971482d-d2fc-4201-a861-843148f94af5" />

  <br/>
  <em>Figure 11: User account creation page</em>
</p>

---

## 2️⃣ Add to Cart

<p align="center">
  
<img width="1898" height="952" alt="Add_Cart" src="https://github.com/user-attachments/assets/85ec1048-e3f0-4f29-8af4-0dfc158e823d" />
  <br/>
  <em>Figure 12: Adding products to the shopping cart</em>
</p>

---

## 3️⃣ Order Checkout

<p align="center">

<img width="1765" height="931" alt="Checking_Out" src="https://github.com/user-attachments/assets/9caae5ad-54c6-47bb-8f1e-13797d717d5f" />

 

  <br/>
  <em>Figure 13: Checkout page for completing orders</em>
</p>

---

## 4️⃣ Order Placed

<p align="center">
 <img width="1751" height="916" alt="Order_Placed" src="https://github.com/user-attachments/assets/2ac6b2f2-2fb4-4a34-9e60-5477da46e2f8" />
  <br/>
  <em>Figure 14: Confirmation page after successfully placing an order</em>
</p>


