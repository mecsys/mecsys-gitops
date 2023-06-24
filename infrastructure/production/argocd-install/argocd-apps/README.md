# Install

    helm repo add argo https://argoproj.github.io/argo-helm

    ARGOCD_APPS_VERSION=1.2.0

    helm secrets template --no-hooks \
        --values values.yaml  \
        argocd-apps \
        argo/argocd-apps \
        --version ${ARGOCD_APPS_VERSION} \
        --namespace argocd | kubectl diff -n argocd -f - | bat -l diff -
    
    helm upgrade argocd-apps argo/argocd-apps --version ${ARGOCD_APPS_VERSION} \
        --install \
        --namespace argocd \
        --create-namespace \
        --values values.yaml