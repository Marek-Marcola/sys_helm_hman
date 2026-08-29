export PATH=/usr/local/bin/alias-hman:$PATH

hm() {
  local desc="@@list chart management (via hman.sh)@@"
  hman.sh $@
}
