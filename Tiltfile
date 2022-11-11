# apply configs and create volumes
k8s_yaml([
  './.k8s/namespace.yaml',
  './.k8s/auth/config.yaml',
  './.k8s/analytics/config.yaml',
  './.k8s/analytics/secrets.yaml',
  './.k8s/billing/config.yaml',
  './.k8s/billing/secrets.yaml',
  './.k8s/task_tracking/config.yaml',
  './.k8s/task_tracking/secrets.yaml',
  './.k8s/pg/pg_config.yaml',
  './.k8s/pg/pg_pv.yaml'])
# apply databases adapters
k8s_yaml(['./.k8s/pg/pg.yaml'])

# <- building images and live changes
docker_build('auth',
   './auth/',
   build_args={},
   dockerfile='./auth/Dockerfile',
   live_update=[sync('auth/app', '/var/www/auth/app/')],
   ignore=['tmp','log']
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
k8s_resource('task-tracking-db-setup', resource_deps=['pg-deployment'])
k8s_resource('task-tracking-deployment', resource_deps=['kafka-broker', 'task-tracking-db-setup'])

# apply processes
k8s_yaml([
  # kafka
  './.k8s/kafka/zookeeper_deployment.yaml',
  './.k8s/kafka/zookeeper_service.yaml',
  './.k8s/kafka/kafka_deployment.yaml',
  './.k8s/kafka/kafka_service.yaml',
  # services
  './.k8s/auth/deployment.yaml',
  './.k8s/auth/service.yaml',
  './.k8s/analytics/deployment.yaml',
  './.k8s/analytics/service.yaml',
  './.k8s/billing/deployment.yaml',
  './.k8s/billing/service.yaml',
  './.k8s/task_tracking/deployment.yaml',
  './.k8s/task_tracking/service.yaml',
  # db jobs
  './.k8s/auth/db_setup.yaml',
  './.k8s/auth/db_seed.yaml',
  './.k8s/analytics/db_setup.yaml',
  './.k8s/billing/db_setup.yaml',
  './.k8s/task_tracking/db_setup.yaml'
])

# <- creates manual/auto action button in the Tilt GUI
# migration
k8s_resource('auth-db-seed', 
   resource_deps=['auth-db-setup'],
   trigger_mode=TRIGGER_MODE_MANUAL,
   auto_init=False
)

# auto/manual display pods in GUI
local_resource('All pods',
  'kubectl get pods --namespace task-tracker',
  resource_deps=[
    'auth-deployment',
    'analytics-deployment',
    'billing-deployment',
    'task-tracking-deployment'
  ]
)
# ->

allow_k8s_contexts('minikube')

k8s_resource('auth-deployment', port_forwards='31000')
k8s_resource('analytics-deployment', port_forwards='32000')
k8s_resource('billing-deployment', port_forwards='33000')
k8s_resource('task-tracking-deployment', port_forwards='34000')
