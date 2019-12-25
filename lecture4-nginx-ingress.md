# 쿠버네티스 버전이 낮을 때 Nginx Ingress 포드가 Pending으로 뜨는 현상

쿠버네티스의 노드에는 자동으로 여러 라벨이 추가되어 있습니다. 예를 들어, kops로 쿠버네티스를 설치했다면 아래처럼 인스턴스 타입 / 운영 체제 타입 등의 라벨이 모든 노드에 설정되어 있습니다.

```
$ kubectl get no --show-labels
NAME                                               STATUS   ROLES    AGE   VERSION    LABELS
ip-172-20-44-203.ap-northeast-2.compute.internal   Ready    node     43m   v1.12.10   beta.kubernetes.io/instance-type=t2.medium,beta.kubernetes.io/os=linux, ....
```

위 명령어의 출력에서 주목해야 하는 라벨은 **beta.kubernetes.io/os=linux** 입니다. 최신 버전의 쿠버네티스에서는 자동으로 추가되는 노드의 라벨이 **kubernetes.io/os: linux** 이지만, kops로 설치한 1.12 버전 전후의 쿠버네티스라면 **beta.kubernetes.io/os=linux** 라벨이 사용되고 있을 것입니다.

문제는, 2019년 12월을 기준으로 nginx ingress controller는 11.2절에서 설명하는 nodeSelector라는 기능을 이용해 **kubernetes.io/os: linux**  라벨이 존재하는 노드에만 포드를 할당하도록 설정되어 있습니다. 따라서 이 이유 때문에 구버전의 쿠버네티스에서는 nginx ingress 포드가 스케줄링 되지 못한 채로 Pending에 막혀있을 수 있습니다.

```
$ kubectl get po -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-75bc5879b6-9fb2h   0/1     Pending   0          9m40s
```

이를 해결하기 위해, 먼저 기존에 배포했던 nginx ingress 컨트롤러를 삭제하겠습니다.

```
$ kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
namespace "ingress-nginx" deleted
configmap "nginx-configuration" deleted
...
```

원본 mandatory.yaml 파일을 내려받은 뒤, nodeSelector에서 사용되는 라벨을 *beta.kubernetes.io/os=linux* 로 변경해 생성합니다.

```
$ wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
$ cat mandatory.yaml | sed 's@kubernetes.io/os@beta.kubernetes.io/os@g' | kubectl apply -f -
namespace/ingress-nginx created
configmap/nginx-configuration created
...
```

정상적으로 nginx ingress 컨트롤러 포드가 생성되었는지 확인합니다.

```
$ kubectl get po -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-8464584596-8trng   1/1     Running   0          39s
```

