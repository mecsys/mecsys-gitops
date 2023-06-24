# Install

    helm repo add argo https://argoproj.github.io/argo-helm

    ARGOCD_VERSION=5.27.5

    helm secrets template --no-hooks \
        --values secrets.yaml  \
        --values values.yaml  \
        argocd \
        argo/argo-cd \
        --version ${ARGOCD_VERSION} \
        --namespace argocd | kubectl diff -n argocd -f - | bat -l diff -
    
    helm secrets upgrade argocd argo/argo-cd --version ${ARGOCD_VERSION} \
        --install \
        --namespace argocd \
        --create-namespace \
        --values secrets.yaml \
        --values values.yaml

# Change pass

    ARGOCDINITIALPASS=12341234
    kubectl patch secret \
        -n argocd argocd-secret \
        -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" ${ARGOCDINITIALPASS} | tr -d ':\n')'"}}'