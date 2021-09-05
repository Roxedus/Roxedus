---
title: Docker development notes
weight: 210
menu:
  notes:
    name: Dev
    identifier: notes-docker-dev
    parent: notes-docker
    weight: 6
---

{{< note title="Quick, desposable test-container" >}}

* Tty in interactive mode. `-it`
* Predictable name. `--name=test`
* Disposable. `--rm`
* Preventes most common orphaned volumes. `--tmpfs /config:rw`
* LSIO ready. `-e TZ=${TZ} -e PUID=${PUID} -e PGID=${PGID}`

```bash
alias tester="docker run --rm -it \
  --name=test --tmpfs /config:rw \
  -e TZ=${TZ} -e PUID=${PUID} -e PGID=${PGID}"
```

{{< /note >}}

{{< note title="Shell access to mentioned test-container" >}}

```bash
alias texec="docker exec -it test /bin/bash"
```

{{< /note >}}

{{< note title="Dive" >}}

Alias for [Dive](https://github.com/wagoodman/dive).

```bash
alias dive="docker run --rm -it --name=dive -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest"
```

{{< /note >}}