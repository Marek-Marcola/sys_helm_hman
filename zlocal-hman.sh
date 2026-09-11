export PATH=/usr/local/bin/alias-hman:$PATH

hm() {
  local desc="@@list chart management (via hman.sh)@@"
  hman.sh $@
}

cdhm() {
  local desc="@@change working directory to hman $EDIR@@"
  local D="/usr/local/etc/hman.d"
  cd $D
  pwd
}
