import random
import json
from kubernetes import client, config, watch

# 이 스케줄러가 담당할 스케줄러 이름을 지정합니다.
scheduler_name = "my-custom-scheduler"

# 이 스케줄러가 스케줄링할 포드의 네임스페이스를 지정합니다. 필요에 따라 전역적으로 사용할 수도 있습니다.
namespace_name = "default"

# 포드 내부에 마운트되어 있는 secret을 읽어옵니다.
config.load_incluster_config()
v1 = client.CoreV1Api()


# 테스트를 위해 랜덤하게 노드를 선택합니다. 별도의 스케줄링 알고리즘을 이 함수에서 구현할 수 있습니다.
def select_node():
    available_nodes = []
    for node in v1.list_node().items:
        for status in node.status.conditions:
            if status.status == "True" and status.type == "Ready":
                available_nodes.append(node.metadata.name)

    selected_node = random.choice(available_nodes)
    return selected_node


# 포드를 특정 노드에 바인딩합니다.
def schedule_pod(pod_name, node_name):
    body = client.V1Binding(
        target=client.V1ObjectReference(
            kind="Node",
            api_version="v1",
            name=node_name
        ),
        metadata=client.V1ObjectMeta(
            name=pod_name
        )
    )

    # From issue https://github.com/kubernetes-client/python/issues/547
    try:
        v1.create_namespaced_binding(namespace=namespace_name, body=body)
    except ValueError:
        pass

    print("Scheduled {} into {}".format(pod_name, node_name))



if __name__ == '__main__':
    # API 서버로부터 Watch를 생성합니다.
    w = watch.Watch()

    # Watch로부터 데이터가 들어오면 스케줄링을 실행합니다.
    for event in w.stream(v1.list_namespaced_pod, namespace_name):
        if event['object'].status.phase == "Pending" and event['object'].spec.scheduler_name == scheduler_name:
            try:
                # 적절한 노드를 선택합니다.
                selected_node = select_node()

                # 포드를 해당 노드에 스케줄링합니다.
                result = schedule_pod(event['object'].metadata.name, selected_node)
            except Exception as e:
                print(json.loads(e.body)['message'])

