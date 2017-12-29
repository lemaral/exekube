resource "helm_release" "chartmuseum" {
  count      = 0
  depends_on = ["cloudflare_record.c6ns_pw"]

  name       = "chartmuseum"
  repository = "${helm_repository.stable.metadata.0.name}"
  chart      = "chartmuseum"
  values     = "${file("/exekube/live/kube/chartmuseum.yaml")}"
}