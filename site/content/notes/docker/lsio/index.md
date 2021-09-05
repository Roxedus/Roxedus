---
title: Linuxserver.io docker notes
weight: 200
menu:
  notes:
    name: LSIO
    identifier: notes-docker-lsio
    parent: notes-docker
    weight: 1
---

{{< note title="Jenkins builder run" >}}

Runs the [Jenkins builder](https://github.com/linuxserver/docker-jenkins-builder) on a local repo, for keeping it in sync.

```bash
alias sync="docker pull ${builder:=lscr.io/linuxserver/jenkins-builder\:latest} && \
docker run --rm \
  -v $(pwd):/tmp \
  -e LOCAL=true \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  ${builder:=lscr.io/linuxserver/jenkins-builder\:latest} && \
rm -rf .jenkins-external"
```

{{< /note >}}
