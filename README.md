# k8s-prelab

1. Azure Cloud Shell 을 실행하고, git clone https://github.com/ye52270/k8s-prelab 명령어 입력해서 VMs코드를 가지고 간다.
    VMs코드는 VM3대를 만드는 만든다. 이 중 1대는 Control Plane, 나머지 2대는 Data Plane 역할을 수행한다.

2. VMs 폴더로 이동해서 아래의 명령어로 테라폼을 실행해준다
  - terraform init
  - terraform plan --var-file module.tfvars
  - tarraform apply --var-file module.tfvars --auto-approve
  
