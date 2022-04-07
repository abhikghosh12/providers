resource "kubernetes_manifest" "constrainttemplate_k8srequiredlabels" {
  manifest = {
    "apiVersion" = "templates.gatekeeper.sh/v1"
    "kind" = "ConstraintTemplate"
    "metadata" = {
      "name" = "k8srequiredlabels"
    }
    "spec" = {
      "crd" = {
        "spec" = {
          "names" = {
            "kind" = "K8sRequiredLabels"
          }
          "validation" = {
            "openAPIV3Schema" = {
              "properties" = {
                "labels" = {
                  "items" = {
                    "type" = "string"
                  }
                  "type" = "array"
                }
              }
              "type" = "object"
            }
          }
        }
      }
      "targets" = [
        {
          "rego" = <<-EOT
          package k8srequiredlabels
          
          violation[{"msg": msg, "details": {"missing_labels": missing}}] {
            provided := {label | input.review.object.metadata.labels[label]}
            required := {label | label := input.parameters.labels[_]}
            missing := required - provided
            count(missing) > 0
            msg := sprintf("you must provide labels: %v", [missing])
          }
          
          EOT
          "target" = "admission.k8s.gatekeeper.sh"
        },
      ]
    }
  }
}
