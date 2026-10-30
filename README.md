# Keepward bench fixtures

Small Docker Compose stacks used to test Keepward on a test machine. Public images only,
no secret, nothing meant for production.

Clone this repository twice on the test machine, then run `up.sh` in each clone:

```sh
git clone -b main    https://github.com/sylvaindnd/keepward-bench-fixtures.git ~/projects/production-keepward-bench-fixtures
git clone -b staging https://github.com/sylvaindnd/keepward-bench-fixtures.git ~/projects/staging-keepward-bench-fixtures
~/projects/production-keepward-bench-fixtures/up.sh
~/projects/staging-keepward-bench-fixtures/up.sh
```

| Folder | Project (production clone) | What it covers |
|---|---|---|
| `web/` | `fixtures-production` | stack with healthchecks behind Traefik, plus a one-shot container that exits |
| `web/redirect/` | `fixtures-production-redirect` | sub-stack in a sub-folder of the same clone |
| `plain/` | `plain` | stack without any healthcheck |
| `legacy/` | `legacy` | stack whose containers are all stopped |
| `web/` | `fixtures-production-old` | orphan project on the same folder and file, one container created |
| none | `fixtures-standalone` | container started outside Compose |

The staging clone (branch `staging`) starts `web/` under its folder name and `web/redirect/`
as `fixtures-staging-redirect`. Project names do not always follow the folder names, on
purpose. `up.sh` needs the Docker network `traefik_network` and is safe to run again.
