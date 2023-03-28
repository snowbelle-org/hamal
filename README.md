# hamal

Minecraft (Spigot) server daemon &amp; toolchain forked from [botan-party/gretel](https://github.com/botan-party/gretel)

## Features

- Spigot compatible
- In-game notice when stopping server
- Use / install optimal JDK
- Auto restart on failure

## Usage

### Installation

1. Create EC2 instance
    - AMI: Amazon Linux 2
    - (Recommended) Instance Type: c6g.large(for 1-5 users) / c6g.xlarge(for 10-20 users)
1. (Recommended) Mount EFS on `/mnt/efs/gretel`
    - (Recommended) Use AWS Backup for EFS
1. (Recommended) Use Elastic IP
1. In server, install Git
1. Run it:

```bash
$ git clone https://github.com/snowbelle-org/hamal
$ cd ./hamal
$ ./setup.sh install $MINECRAFT_VERSION
```

1. Set optimal memory caps
    - Edit `/mnt/efs/gretel/manage.sh`
1. Run it:

```bash
$ sudo systemctl start hamal
```

### Attach minecraft server console

```bash
$ screen -r hamal
```

## LICENSE

MIT
