# acme-issuers

A small Helm chart for setting up a standard set of ACME [cert-manager](https://cert-manager.io/) `ClusterIssuer`s, without copying and pasting the same YAML into every cluster.

I use it with my [NKP Custom Catalog](https://github.com/markround/nkp-catalog). It lets me deploy the same issuers to every NKP cluster in a workspace, whatever each cluster runs on (Nutanix NCI, vSphere, AWS, Azure and so on). It's a plain Helm chart though, so it should work on any cluster that has cert-manager installed.

## What you get

Out of the box, you get two issuers that use an HTTP-01 solver through the `kommander-traefik` ingress class:

- `letsencrypt-staging`
- `letsencrypt-prod`

You'll probably want to at least change the email address. Everything else is optional.

## Installing

The chart is published as an OCI artifact to GitHub Container Registry:

```bash
helm install acme-issuers oci://ghcr.io/markround/helm/acme-issuers \
  --version 0.4.1 \
  --set email=you@example.com
```

## Configuration

As usual, all configuration is done through [values.yaml](values.yaml), which has plenty of comments and a few examples. Here's a quick tour:

| Value            | What it does                                                                      |
| ---------------- | --------------------------------------------------------------------------------- |
| `email`          | Account email for all issuers. You can override it per issuer.                    |
| `ingressClass`   | Ingress class for the default HTTP-01 solver.                                     |
| `solvers`        | Global list of solvers, in cert-manager's `spec.acme.solvers` format.             |
| `clusterIssuers` | The issuers to create. Each needs a `name` and `url`, and can set its own `email` and `solvers`. |


Solver lists are copied into the `ClusterIssuer` exactly as you write them, so any solver cert-manager supports will work.

### Example: wildcard certs with Cloudflare

HTTP-01 can't issue wildcard certificates, so you could switch the prod issuer (or create an additional one) to DNS-01:

```yaml
email: you@example.com

clusterIssuers:
  - name: letsencrypt-staging
    url: https://acme-staging-v02.api.letsencrypt.org/directory
  - name: letsencrypt-prod
    url: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
```

Important - if you do this, the referenced secret needs to already exist in the cert-manager namespace.

## Releases

A GitHub Actions workflow packages the chart and pushes it to `ghcr.io` on every push:

- **Tags** (`v0.4.1` or `0.4.1`) publish a release. The tag has to match `version` in `Chart.yaml`.
- **Branches** publish a pre-release build tagged `<chart-version>-<branch>`, e.g. `0.4.1-main`. These are handy for testing.
