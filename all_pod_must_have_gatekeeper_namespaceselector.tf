resource "kubernetes_manifest" "k8srequiredlabels_pod_must_have_gk" {
  manifest = {
    "apiVersion" = "constraints.gatekeeper.sh/v1beta1"
    "kind" = "K8sRequiredLabels"
    "metadata" = {
      "name" = "pod-must-have-gk"
    }
    "spec" = {
      "match" = {
        "kinds" = [
          {
            "apiGroups" = [
              "",
            ]
            "kinds" = [
              "Pod",
            ]
          },
        ]
        "namespaceSelector" = {
          "matchExpressions" = [
            {
              "key" = "workloadtype"
              "operator" = "In"
              "values" = [
                "prodworkload",
              ]
            },
          ]
        }
      }
      "parameters" = {
        "labels" = [
          "gatekeeper",
        ]
      }
    }
  }
}
