from kubernetes import client, config
config.load_incluster_config() # 1

try:
  print('Trying to list service..')
  result = client.CoreV1Api().list_namespaced_service(namespace='default') # 2
  for item in result.items:
    print('-> {}'.format(item.metadata.name))
except client.rest.ApiException as e:
  print(e)

print('----')

try:
  print('Trying to list pod..')
  result = client.CoreV1Api().list_namespaced_pod(namespace='default') # 3
  for item in result.items:
    print(item.metadata.name)
except client.rest.ApiException as e:
  print(e)
