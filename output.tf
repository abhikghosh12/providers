resource "kubernetes_manifest" "clusterrole_proxy_clusterrole_kubeapiserver" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "proxy-clusterrole-kubeapiserver"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes/metrics",
          "nodes/proxy",
          "nodes/stats",
          "nodes/log",
          "nodes/spec",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_proxy_role_binding_kubernetes_master" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "proxy-role-binding-kubernetes-master"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "proxy-clusterrole-kubeapiserver"
    }
    "subjects" = [
      {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind" = "User"
        "name" = "kube-apiserver"
      },
    ]
  }
}

resource "kubernetes_manifest" "namespace_cattle_system" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "cattle-system"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_cattle_system_cattle" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "cattle"
      "namespace" = "cattle-system"
    }
  }
}

resource "kubernetes_manifest" "clusterrolebinding_cattle_system_cattle_admin_binding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "cattle.io/creator" = "norman"
      }
      "name" = "cattle-admin-binding"
      "namespace" = "cattle-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "cattle-admin"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "cattle"
        "namespace" = "cattle-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "secret_cattle_system_cattle_credentials_898674f" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "namespace" = ""
      "token" = "dmJrdGxxd3Y5bnNtbG5ua3MydG5uZDhudDZiaGx3dGp4dDZ2czlycmJ0NW54aHpnazgyODl2"
      "url" = "aHR0cHM6Ly92MDAwMjQ5NS5rbmUuYnVuZC5kcnY="
    }
    "kind" = "Secret"
    "metadata" = {
      "name" = "cattle-credentials-898674f"
      "namespace" = "cattle-system"
    }
    "type" = "Opaque"
  }
}

resource "kubernetes_manifest" "clusterrole_cattle_admin" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "cattle.io/creator" = "norman"
      }
      "name" = "cattle-admin"
    }
    "rules" = [
      {
        "apiGroups" = [
          "*",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "nonResourceURLs" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_cattle_system_cattle_cluster_agent" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "annotations" = {
        "management.cattle.io/scale-available" = "2"
      }
      "name" = "cattle-cluster-agent"
      "namespace" = "cattle-system"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "cattle-cluster-agent"
        }
      }
      "strategy" = {
        "rollingUpdate" = {
          "maxSurge" = 1
          "maxUnavailable" = 0
        }
        "type" = "RollingUpdate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "cattle-cluster-agent"
          }
        }
        "spec" = {
          "affinity" = {
            "nodeAffinity" = {
              "preferredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "preference" = {
                    "matchExpressions" = [
                      {
                        "key" = "node-role.kubernetes.io/controlplane"
                        "operator" = "In"
                        "values" = [
                          "true",
                        ]
                      },
                    ]
                  }
                  "weight" = 100
                },
                {
                  "preference" = {
                    "matchExpressions" = [
                      {
                        "key" = "node-role.kubernetes.io/control-plane"
                        "operator" = "In"
                        "values" = [
                          "true",
                        ]
                      },
                    ]
                  }
                  "weight" = 100
                },
                {
                  "preference" = {
                    "matchExpressions" = [
                      {
                        "key" = "node-role.kubernetes.io/master"
                        "operator" = "In"
                        "values" = [
                          "true",
                        ]
                      },
                    ]
                  }
                  "weight" = 100
                },
                {
                  "preference" = {
                    "matchExpressions" = [
                      {
                        "key" = "cattle.io/cluster-agent"
                        "operator" = "In"
                        "values" = [
                          "true",
                        ]
                      },
                    ]
                  }
                  "weight" = 1
                },
              ]
              "requiredDuringSchedulingIgnoredDuringExecution" = {
                "nodeSelectorTerms" = [
                  {
                    "matchExpressions" = [
                      {
                        "key" = "beta.kubernetes.io/os"
                        "operator" = "NotIn"
                        "values" = [
                          "windows",
                        ]
                      },
                    ]
                  },
                ]
              }
            }
            "podAntiAffinity" = {
              "preferredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "podAffinityTerm" = {
                    "labelSelector" = {
                      "matchExpressions" = [
                        {
                          "key" = "app"
                          "operator" = "In"
                          "values" = [
                            "cattle-cluster-agent",
                          ]
                        },
                      ]
                    }
                    "topologyKey" = "kubernetes.io/hostname"
                  }
                  "weight" = 100
                },
              ]
            }
          }
          "containers" = [
            {
              "env" = [
                {
                  "name" = "CATTLE_IS_RKE"
                  "value" = "false"
                },
                {
                  "name" = "CATTLE_SERVER"
                  "value" = "https://v0002495.kne.bund.drv"
                },
                {
                  "name" = "CATTLE_CA_CHECKSUM"
                  "value" = "9b9b96cde201bc69bf416cd72d98e3950927fc6a063d085e1390f4073e8f714a"
                },
                {
                  "name" = "CATTLE_CLUSTER"
                  "value" = "true"
                },
                {
                  "name" = "CATTLE_K8S_MANAGED"
                  "value" = "true"
                },
                {
                  "name" = "CATTLE_CLUSTER_REGISTRY"
                  "value" = ""
                },
                {
                  "name" = "CATTLE_SERVER_VERSION"
                  "value" = "v2.6.3-patch1"
                },
                {
                  "name" = "CATTLE_INSTALL_UUID"
                  "value" = "86e3ac3a-01ea-4ee6-a7dc-3d392294c808"
                },
                {
                  "name" = "CATTLE_INGRESS_IP_DOMAIN"
                  "value" = "sslip.io"
                },
              ]
              "image" = "rancher/rancher-agent:v2.6.3-patch1"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "cluster-register"
              "volumeMounts" = [
                {
                  "mountPath" = "/cattle-credentials"
                  "name" = "cattle-credentials"
                  "readOnly" = true
                },
              ]
            },
          ]
          "serviceAccountName" = "cattle"
          "tolerations" = [
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/controlplane"
              "value" = "true"
            },
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/control-plane"
              "operator" = "Exists"
            },
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/master"
              "operator" = "Exists"
            },
          ]
          "volumes" = [
            {
              "name" = "cattle-credentials"
              "secret" = {
                "defaultMode" = 320
                "secretName" = "cattle-credentials-898674f"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_cattle_system_cattle_cluster_agent" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "cattle-cluster-agent"
      "namespace" = "cattle-system"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 80
          "protocol" = "TCP"
          "targetPort" = 80
        },
        {
          "name" = "https-internal"
          "port" = 443
          "protocol" = "TCP"
          "targetPort" = 444
        },
      ]
      "selector" = {
        "app" = "cattle-cluster-agent"
      }
    }
  }
}
