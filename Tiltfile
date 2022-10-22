# apply configs and create volumes
k8s_yaml([
  './.k8s/namespace.yaml',
  './.k8s/services/auth_config.yaml',
  './.k8s/services/analytics_config.yaml',
  './.k8s/services/billing_config.yaml',
  './.k8s/services/task_tracker_config.yaml',
  './.k8s/pg/pg_config.yaml',
  './.k8s/pg/pg_pv.yaml'])
# apply databases adapters
k8s_yaml(['./.k8s/pg/pg.yaml'])

# <- building images and live changes
docker_build('auth',
   './auth/',
   build_args={},
   dockerfile='./auth/Dockerfile'
)
docker_build('analytics',
   './analytics/',
   build_args={},
   dockerfile='./analytics/Dockerfile'
)
docker_build('billing',
   './billing/',
   build_args={},
   dockerfile='./billing/Dockerfile'
)
docker_build('task_tracking',
   './task_tracking/',
   build_args={},
   dockerfile='./task_tracking/Dockerfile'
)
# -> end images

# deployments dependencies
k8s_resource('kafka-broker', resource_deps=['zookeeper'])
k8s_resource('auth-db-setup', resource_deps=['pg-deployment'])
k8s_resource('auth-deployment', resource_deps=['kafka-broker', 'auth-db-setup'])
k8s_resource('analytics-db-setup', resource_deps=['pg-deployment'])
k8s_resource('analytics-deployment', resource_deps=['kafka-broker', 'analytics-db-setup'])
k8s_resource('billing-db-setup', resource_deps=['pg-deployment'])
k8s_resource('billing-deployment', resource_deps=['kafka-broker', 'billing-db-setup'])
k8s_resource('task-tracker-db-setup', resource_deps=['pg-deployment'])
k8s_resource('task-tracker-deployment', resource_deps=['kafka-broker', 'task-tracker-db-setup'])

# apply processes
k8s_yaml([
  # kafka
  './.k8s/kafka/zookeeper_deployment.yaml',
  './.k8s/kafka/zookeeper_service.yaml',
  './.k8s/kafka/kafka_deployment.yaml',
  './.k8s/kafka/kafka_service.yaml',
  # services
  './.k8s/services/auth_deployment.yaml',
  './.k8s/services/auth_service.yaml',
  './.k8s/services/analytics_deployment.yaml',
  './.k8s/services/analytics_service.yaml',
  './.k8s/services/billing_deployment.yaml',
  './.k8s/services/billing_service.yaml',
  './.k8s/services/task_tracker_deployment.yaml',
  './.k8s/services/task_tracker_service.yaml',
  # db jobs
  './.k8s/services/auth_db_setup.yaml',
  './.k8s/services/analytics_db_setup.yaml',
  './.k8s/services/billing_db_setup.yaml',
  './.k8s/services/task_tracker_db_setup.yaml'
])

# auto/manual display pods in GUI
local_resource('All pods',
  'kubectl get pods --namespace task-tracker',
  resource_deps=[
    'auth-deployment',
    'analytics-deployment',
    'billing-deployment',
    'task-tracker-deployment'
  ]
)

local_resource('Seed auth database',
  'bundle exec rails db:seed',
  resource_deps=['auth-deployment'],
  dir='./auth/',
  trigger_mode=TRIGGER_MODE_MANUAL,
  auto_init=False
)
# ->

allow_k8s_contexts('minikube')

k8s_resource('auth-deployment', port_forwards='31000')
k8s_resource('analytics-deployment', port_forwards='32000')
k8s_resource('billing-deployment', port_forwards='33000')
k8s_resource('task-tracker-deployment', port_forwards='34000')
