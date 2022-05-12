---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: proxy-clusterrole-kubeapiserver
rules:
- apiGroups: [""]
  resources:
  - nodes/metrics
  - nodes/proxy
  - nodes/stats
  - nodes/log
  - nodes/spec
  verbs: ["get", "list", "watch", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: proxy-role-binding-kubernetes-master
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: proxy-clusterrole-kubeapiserver
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: kube-apiserver
---
apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: cattle
  namespace: cattle-system

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cattle-admin-binding
  namespace: cattle-system
  labels:
    cattle.io/creator: "norman"
subjects:
- kind: ServiceAccount
  name: cattle
  namespace: cattle-system
roleRef:
  kind: ClusterRole
  name: cattle-admin
  apiGroup: rbac.authorization.k8s.io

---

apiVersion: v1
kind: Secret
metadata:
  name: cattle-credentials-898674f
  namespace: cattle-system
type: Opaque
data:
  url: "aHR0cHM6Ly92MDAwMjQ5NS5rbmUuYnVuZC5kcnY="
  token: "dmJrdGxxd3Y5bnNtbG5ua3MydG5uZDhudDZiaGx3dGp4dDZ2czlycmJ0NW54aHpnazgyODl2"
  namespace: ""

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cattle-admin
  labels:
    cattle.io/creator: "norman"
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: cattle-cluster-agent
  namespace: cattle-system
  annotations:
    management.cattle.io/scale-available: "2"
spec:
  selector:
    matchLabels:
      app: cattle-cluster-agent
  template:
    metadata:
      labels:
        app: cattle-cluster-agent
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - cattle-cluster-agent
              topologyKey: kubernetes.io/hostname
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                - key: beta.kubernetes.io/os
                  operator: NotIn
                  values:
                    - windows
          preferredDuringSchedulingIgnoredDuringExecution:
          - preference:
              matchExpressions:
              - key: node-role.kubernetes.io/controlplane
                operator: In
                values:
                - "true"
            weight: 100
          - preference:
              matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: In
                values:
                - "true"
            weight: 100
          - preference:
              matchExpressions:
              - key: node-role.kubernetes.io/master
                operator: In
                values:
                - "true"
            weight: 100
          - preference:
              matchExpressions:
              - key: cattle.io/cluster-agent
                operator: In
                values:
                - "true"
            weight: 1
      serviceAccountName: cattle
      tolerations:
      # No taints or no controlplane nodes found, added defaults
      - effect: NoSchedule
        key: node-role.kubernetes.io/controlplane
        value: "true"
      - effect: NoSchedule
        key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
      - effect: NoSchedule
        key: "node-role.kubernetes.io/master"
        operator: "Exists"
      containers:
        - name: cluster-register
          imagePullPolicy: IfNotPresent
          env:
          - name: CATTLE_IS_RKE
            value: "false"
          - name: CATTLE_SERVER
            value: "https://v0002495.kne.bund.drv"
          - name: CATTLE_CA_CHECKSUM
            value: "9b9b96cde201bc69bf416cd72d98e3950927fc6a063d085e1390f4073e8f714a"
          - name: CATTLE_CLUSTER
            value: "true"
          - name: CATTLE_K8S_MANAGED
            value: "true"
          - name: CATTLE_CLUSTER_REGISTRY
            value: ""
          - name: CATTLE_SERVER_VERSION
            value: v2.6.3-patch1
          - name: CATTLE_INSTALL_UUID
            value: 86e3ac3a-01ea-4ee6-a7dc-3d392294c808
          - name: CATTLE_INGRESS_IP_DOMAIN
            value: sslip.io
          image: rancher/rancher-agent:v2.6.3-patch1
          volumeMounts:
          - name: cattle-credentials
            mountPath: /cattle-credentials
            readOnly: true
      volumes:
      - name: cattle-credentials
        secret:
          secretName: cattle-credentials-898674f
          defaultMode: 320
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1

---
apiVersion: v1
kind: Service
metadata:
  name: cattle-cluster-agent
  namespace: cattle-system
spec:
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 444
    protocol: TCP
    name: https-internal
  selector:
    app: cattle-cluster-agent
