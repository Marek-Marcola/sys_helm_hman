helm hman
=========

Helm release management tools.

Install
-------
Install:

    ./hman.sh --install

    cp -fv hman.sh /usr/local/bin/hman.sh
    cp -fv hman.sh /usr/local/bin/hman-exec.sh

Verify:

    hman.sh --version

Help:

    hman.sh --help

Alias:

    # cat > /etc/profile.d/zlocal-hman.sh <<\EOF
    export PATH=/usr/local/bin/alias-hman:$PATH
    
    hm() {
      local desc="@@list chart management (via hman.sh)@@"
      hman.sh $@
    }
    EOF
