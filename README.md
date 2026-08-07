helm hman
=========

Helm chart management tools.

Install
-------
Install:

    hman.sh --inst -x
    -- or --
    hman.sh --anpb -x
    -- or --
    cp -fv hman.sh /usr/local/bin/hman.sh
    cp -fv hman.sh /usr/local/bin/hman-exec.sh

    mkdir -pv /usr/local/etc/hman.d
    mkdir -pv /usr/local/bin/alias-hman

Postinstall:

    # cat > /etc/profile.d/zlocal-hman.sh <<\EOF
    export PATH=/usr/local/bin/alias-hman:$PATH
    
    hm() {
      local desc="@@helm chart management (via hman.sh)@@"
      hman.sh $@
    }
    EOF

Verify:

    hman.sh --ver

Help:

    hman.sh --help
