# k8s-prelab

## 테라폼으로 VM 3대 구성
1. Azure Cloud Shell 을 실행하고, git clone https://github.com/ye52270/k8s-prelab 명령어 입력해서 VMs코드를 가지고 간다.
    VMs코드는 VM3대를 만드는 만든다. 이 중 1대는 Control Plane, 나머지 2대는 Data Plane 역할을 수행한다.

2. VMs 폴더로 이동해서 아래의 명령어로 테라폼을 실행해준다
  - terraform init
  - terraform plan --var-file module.tfvars
  - tarraform apply --var-file module.tfvars --auto-approve

## 쿠버네티스 설치
1. Control Plane 에 접속해서 host 명을 변경한다 
  - sudo -i
  - sudo hostnamectl set-hostname k8s-master
  - sudo -i
2. swap 해제
  - swapoff -a
  - sudo sed -i '/ swap / s/^/#/' /etc/fstab
3. 방화벽 해제
  - sudo ufw disable
4. 패키지 업데이트
  - sudo apt-get update -y
5. IPSTABLE 확인('net.bridge.bridge-nf-call-iptables의 값이 1로 설정되어 있는지 확인')

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    br_netfilter
    EOF
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sudo sysctl --system
 6. docker 설치
 
    sudo apt-get -y update
    sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  7. Docker의 공식 GPG 키 추가
  
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |\
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  8. Stable 저장소 설정
  
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   9. docker 설치
   
       sudo apt-get -y update
       sudo apt-get -y install docker-ce docker-ce-cli containerd.io
   10. CGROUP 설정
   
         sudo mkdir /etc/docker
        cat <<EOF | sudo tee /etc/docker/daemon.json
        {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
        "max-size": "100m"
        },
        "storage-driver": "overlay2"
        }
        EOF
        
    11. Docker 실행 및 확인
    
        sudo systemctl enable docker
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        sudo systemctl status docker
    12. kubeadm, kubelet, kubectl 설치
    
        sudo apt-get -y update
        sudo apt-get install -y apt-transport-https ca-certificates curl
    13. Google Cloud 공개 서명 키를 다운로드
    
        sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
        https://packages.cloud.google.com/apt/doc/apt-key.gpg
    14. Kubernetes apt리포지토리를 추가
    
        echo "deb \
        [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
        https://apt.kubernetes.io/ kubernetes-xenial main" | \
        sudo tee /etc/apt/sources.list.d/kubernetes.list
    15. apt 패키지 색인을 업데이트하고, kubelet, kubeadm, kubectl을 설치하고 해당 버전을 고정
    
        sudo apt-get -y update
        sudo apt-get install -y kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
    16. kubeadm 초기화
    
        kubeadm init --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=<Control Plane 의 Private IP>
        
    * kubeadm init 할 때 container runtime is not running 오류가 날 경우 아래와 같이 조치를 해 준다
    
       1) rm /etc/containerd/config.toml
       2) systemctl restart containerd
        
       join 명령어를 잘 복사하고, Contol Plane 의 두대 서버에서 1~15번까지 반복해준다.
     17. Control Plane 구성이 완료되면 아래 명령어를 Control Plane 에서 실행해 준다
     
        mkdir -p $HOME/.kube
        
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        
        export KUBECONFIG=/etc/kubernetes/admin.conf
        
     18. Control Plane 에서 Calico 네트워크 플러그인 설치
     
       - kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
        
        


        
