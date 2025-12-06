#!/bin/bash

VERSION_BIN="202512070061"

SN="${0##*/}"
ID="[$SN]"

SDIR="/dep/c"
DDIR="/var/backup/hman"

INSTALL=0
VERSION=0
BACKUP=0
BACKUP_LIST=0
LINK=0
EXEC=0
EVAL=0
ELIST=0
ESHOW=0
ESHOW_ALL=0
EEDIT=0
EEDIT_TEMPLATE=0
RLIST=0
RUPDATE=0
RSEARCH=0
CSHOW=0
ADIFF=0
AINIT=0
AINSTALL=0
AUNINSTALL=0
ALIST=0
AHISTORY=0
AMANIFEST=0
ACHART=0
ALOG=0
RRESTART=0
RHISTORY=0
RSTATUS=0
RSCALE=""
SLIST=0
SLOAD=0
HELP=0
QUIET=0

declare -a ARGS1
declare -a OPTS2
ARGS2=""
REXP=""

s=0

: ${A:=$(basename ${BASH_SOURCE%.sh})}
: ${EDIR:="/usr/local/etc/hman.d"}
: ${BDIR:="/usr/local/bin/alias-hman"}
: ${COMM:=$(readlink -f ${BASH_SOURCE})}

if [ $# -eq 0 ]; then
  if [ "$A" = "hman" ]; then
    ELIST=1
    QUIET=1
  else
    AHISTORY=1
  fi
fi

if [[ $COMM == *hman-exec.sh ]]; then
  set - -- $*
  QUIET=1
fi

while [ $# -gt 0 ]; do
  case $1 in
    --inst*|-inst*)
      INSTALL=1
      shift
      ;;
    --vers*|-vers*)
      VERSION=1
      shift
      ;;
    -B)
      BACKUP=1
      BACKUP_LIST=1
      shift
      ;;
    -Bl)
      BACKUP_LIST=1
      shift
      ;;
    -A)
      A="$2"
      shift; shift
      ;;
    -V)
      V="$2"
      shift; shift
      ;;
    -C)
      C="$2"
      shift; shift
      ;;
    -N)
      N="$2"
      shift; shift
      ;;
    -T)
      T="$2"
      shift; shift
      ;;
    -Ed)
      EDIR="$2"
      shift; shift
      ;;
    -Bd)
      BDIR="$2"
      shift; shift
      ;;
    -L)
      LINK=1
      shift
      ;;
    -x)
      EVAL=1
      shift
      ;;
    -e)
      EXEC=1
      QUIET=1
      shift
      ARGS2=$*
      break
      ;;
    -l)
      ELIST=1
      shift
      ;;
    -s)
      ESHOW=1
      shift
      ;;
    -S*)
      [[ "$1" != "-S" ]] && REXP=${1:2}
      ESHOW_ALL=1
      QUIET=1
      shift
      ;;
    -E)
      EEDIT=1
      shift
      ;;
    -Et)
      EEDIT_TEMPLATE=1
      shift
      ;;
    -rl)
      RLIST=1
      shift
      ;;
    -ru)
      RUPDATE=1
      shift
      ;;
    -r)
      RSEARCH=1
      shift
      ;;
    -c)
      CSHOW=1
      shift
      ;;
    -cr)
      CSHOW=2
      shift
      ;;
    -cv)
      CSHOW=3
      shift
      ;;
    -D)
      ADIFF=1
      shift
      ;;
    --init|-init)
      AINIT=1
      shift
      ;;
    -iu)
      AINSTALL=1
      shift
      ;;
    -u)
      AUNINSTALL=1
      shift
      ;;
    -a)
      ALIST=1
      QUIET=1
      shift
      ;;
    -ah)
      AHISTORY=1
      shift
      ;;
    -am)
      AMANIFEST=1
      shift
      ;;
    -ac)
      ACHART=1
      shift
      ;;
    -al)
      ALOG=1
      shift
      ;;
    -RR)
      RRESTART=1
      RSTATUS=1
      shift
      ;;
    -RH)
      RHISTORY=1
      shift
      ;;
    -RS)
      RSTATUS=1
      shift
      ;;
    -la)
      SLOAD=1
      shift
      ;;
    -ls)
      SLIST=1
      shift
      ;;
    -R[[:digit:]]*)
      RSCALE=${1:2}
      shift
      ;;
    -h|-help|--help)
      HELP=1
      shift
      ;;
    -q)
      QUIET=1
      shift
      ;;
    --)
      shift
      ARGS2=$*
      break
      ;;
    *)
      OPTS2+=("$1")
      shift
      ;;
  esac
done

#
# stage: HELP
#
if [ $HELP -eq 1 ]; then
  echo "$SN -install         # install"
  echo "$SN -version         # version"
  echo "$SN -B               # backup"
  echo "$SN -Bl              # backup list"
  echo ""
  echo "$SN -L [-x]          # link show,run"
  echo ""
  echo "$SN -e [args2]       # exec"
  echo "$SN -rl              # repo list"
  echo "$SN -ru [repo]       # repo update"
  echo "$SN -r [keyword]     # repo search"
  echo "$SN -c               # chart info"
  echo "$SN -cr              # chart readme"
  echo "$SN -cv              # chart values"
  echo "$SN -D               # app diff yaml"
  echo ""
  echo "$SN -init [-x]       # app init show/run"
  echo "$SN -iu   [-x]       # app install/update"
  echo "$SN -u    [-x]       # app uninstall"
  echo "$SN -a               # app list"
  echo "$SN -ah              # app history"
  echo "$SN -am              # app manifest"
  echo "$SN -ac              # app chart"
  echo "$SN -al              # app log"
  echo ""
  echo "$SN -RR              # res rollout restart"
  echo "$SN -RH              # res rollout history"
  echo "$SN -RS              # res rollout status"
  echo "$SN -Rn              # res scale replicas to n"
  echo ""
  echo "$SN -la              # spooler load,archive"
  echo "$SN -ls              # spooler list"
  echo ""
  echo "$SN -l               # env list"
  echo "$SN -s               # env show"
  echo "$SN -S[rexp]         # env show all"
  echo "$SN -E               # env edit"
  echo "$SN -Et              # env edit with template"
  echo "$SN                  # env list/app history"
  echo ""
  echo "opts:"
  echo "  -A  release name"
  echo "  -V  chart version"
  echo "  -C  chart name"
  echo "  -N  namespace"
  echo "  -T  type"
  echo "  -Ed edir ($EDIR)"
  echo "  -Bd ldir ($BDIR)"
  echo "  -Sd sdir ($SDIR)"
  echo ""
  echo "env files: /usr/local/etc/hman.env $EDIR/\$A \$HOME/.hman.env .hman.env \$HMANENV"
  echo "env vars:"
  echo "  \$A - release name"
  echo "  \$V - chart version"
  echo "  \$C - chart name"
  echo "  \$N - namespace"
  echo "  \$T - type"
  echo ""
  echo "notes:"
  echo "  hm -L -x            # link"
  echo "  ap-apn-api -init -x # init"
  echo ""
  echo "  ap-apn-api -ru -r   # repo update/show"
  echo "  ap-apn-api -E       # env edit"
  echo "  ap-apn-api -D       # app diff"
  echo "  ap-apn-api -iu -x   # install/update"
  echo "  ap-apn-api -u -x    # uninstall"
  exit 0
fi

#
# stage: CONFIG
#
for f in /usr/local/etc/hman.env $EDIR/$A $HOME/.hman.env .hman.env $CMANENV; do
  if [ -e $f ]; then
    [[ "$EFILE" != "" ]] && EFILE="$EFILE $f" || EFILE="$f"
    . ${f}
  fi
done

if [ "$T" = "" ]; then
  T=deployment
fi

if [ "$ETEMPLATE" = "" ]; then
ETEMPLATE=': ${V:=0}
: ${C:=scm/chart}
OPTS=(
)'
fi

#
# stage: VERSION
#
if [ $VERSION -eq 1 ]; then
  echo "${0##*/}  $VERSION_BIN"
  if [ $(type -t helm) ]; then
    set -ex
    helm version
    { set +ex; } 2>/dev/null
  fi
  exit 0
fi

#
# stage: INSTALL
#
if [ $INSTALL -eq 1 ]; then
  if [ -f hman.sh ]; then
    for d in /usr/local/bin /pub/pkb/kb/data/999222-hman/999222-000020_hman_script /pub/pkb/pb/playbooks/999222-hman/files; do
      if [ -d $d ]; then
        set -ex
        rsync -ai hman.sh $d
        { set +ex; } 2>/dev/null
      fi
    done
  fi
  exit 0
fi

#
# stage: INFO
#
if [ $QUIET -eq 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: INFO"

  [[ -n $INFO ]] && echo "info   = ${INFO}"
  echo "cwd    = $(pwd -P)"
  echo "efile  = ${EFILE:-[none]}"
  echo "App    = ${A:-[none]}"
  echo "Ver    = ${V:-[none]}"
  echo "Chart  = ${C:-[none]}"
  echo "Nspace = ${N:-[none]}"
  echo "Type   = ${T:-[none]}"
  echo "wdir   = ${WDIR:-[none]}"
  echo "edir   = ${EDIR:-[none]}"
  echo "bdir   = ${BDIR:-[none]}"
  echo "comm   = ${COMM:-[none]}"

  if [ "$OPTS" != "" ]; then
    echo "opts   = $(echo ${OPTS[@]}|sed 's/--/\n--/g'|grep -v '^$'|sed '2,$s/^--/         --/')"
  else
    echo "opts   = [none]"
  fi
  if [ "$OPTS2" != "" ]; then
    echo "opts2  = ${OPTS2[@]}"
  else
    echo "opts2  = [none]"
  fi

  echo "args   = ${ARGS:-[none]}"
  echo "args2  = ${ARGS2:-[none]}"

  if [ "$INIT" != "" ]; then
    echo -n "init   = "
    for cmd in "${INIT[@]}"; do
      echo $cmd
    done | sed '2,$s/^/         /'
  else
    echo "init   = [none]"
  fi

  if [ "$DOCS" != "" ]; then
    echo -n "docs   = "
    echo "$DOCS" | sed 's/\!/\n/g' | sed '2,$ s/^/         /'
  fi
fi

#
# stage: LINK
#
if [ $LINK -ne 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: LINK"

  if [ ! -d $EDIR ]; then
    echo $ID: directory not found: $EDIR
    exit 1
  fi
  if [ ! -d $BDIR ]; then
    echo $ID: directory not found: $BDIR
    exit 1
  fi

  ls $EDIR/ | \
  while read E; do
    if grep -q EXEC=1 $EDIR/$E; then
      LSRC=${COMM%.sh}-exec.sh
    else
      LSRC=${COMM}
    fi
    if [ ! -f $BDIR/$E ]; then
      if [ $EVAL -ne 0 ]; then
        set -ex
        ln -svr $LSRC $BDIR/$E
        { set +ex; } 2>/dev/null
      else
        echo "ln -svr $LSRC $BDIR/$E"
      fi
    else
      echo "# ln -svr $LSRC $BDIR/$E"
    fi
  done
fi

#
# stage: EXEC
#
if [ $EXEC -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: EXEC"

  if [ "$WDIR" != "" ]; then
    set -ex
    cd $WDIR
    { set +ex; } 2>/dev/null
  fi
fi

#
# stage: ENV-LIST
#
if [ $ELIST -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: ENV-LIST"

  if [ ! -d $EDIR ]; then
    echo directory not found: $EDIR
  else
    set -ex
    ls -log $EDIR/
    { set +ex; } 2>/dev/null
  fi
fi

#
# stage: ENV-SHOW
#
if [ $ESHOW -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: ENV-SHOW"

  if [ ! -f $EDIR/$A ]; then
    echo file not found: $EDIR/$A
  else
    set -ex
    cat $EDIR/$A
    { set +ex; } 2>/dev/null
  fi
fi

#
# stage: ENV-SHOW-ALL
#
if [ $ESHOW_ALL -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: ENV-SHOW-ALL (rexp: *$REXP*)"

  if [ ! -d $EDIR ]; then
    echo directory not found: $EDIR
  else
    (
    for f in $EDIR/*$REXP*; do
      if [ -f $f ]; then
        echo | xargs -L1 -t cat $f 2>&1
        echo
      fi
    done
    ) | sed '${/^$/d;}'
  fi
fi

#
# stage: ENV-EDIT
#
if [ $EEDIT -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: ENV-EDIT"

  if [ ! -d $EDIR ]; then
    echo directory not found: $EDIR
  else
    set -ex
    vi $EDIR/$A
    { set +ex; } 2>/dev/null
  fi
fi

#
# stage: ENV-EDIT-TEMPLATE
#
if [ $EEDIT_TEMPLATE -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: ENV-EDIT-TEMPLATE"

  if [ ! -d $EDIR ]; then
    echo directory not found: $EDIR
  else
    if [ ! -f $EDIR/$A ]; then
      echo create file: $EDIR/$A
      echo "$ETEMPLATE" > $EDIR/$A
    else
      echo file exists: $EDIR/$A
    fi
    set -ex
    vi $EDIR/$A
    { set +ex; } 2>/dev/null
  fi
fi

#
# stage: REPO-LIST
#
if [ $RLIST -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: REPO-LIST"

  set -ex
  helm repo list
  { set +ex; } 2>/dev/null
fi

#
# stage: REPO-UPDATE
#
if [ $RUPDATE -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: REPO-UPDATE"

  if [ "$OPTS2" != "" ]; then
    O="$OPTS2"
  else
    if [ "$A" != "hman" ]; then
      O="$(echo $C|awk -F/ '{print $1}')"
    else
      O=""
    fi
  fi

  set -ex
  helm repo update $O
  { set +ex; } 2>/dev/null
fi

#
# stage: REPO-SEARCH
#
if [ $RSEARCH -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: REPO-SEARCH"

  if [ "$OPTS2" != "" ]; then
    O="$OPTS2 -l"
  else
    if [ "$A" != "hman" ]; then
      O="$C -l"
    else
      O=""
    fi
  fi

  set -ex
  helm search repo $O
  { set +ex; } 2>/dev/null
fi

#
# stage: CHART-SHOW
#
if [ $CSHOW -ne 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: CHART-SHOW"

  if [ $CSHOW -eq 1 ]; then
    set -ex
    helm show chart $C
    { set +ex; } 2>/dev/null
  elif [ $CSHOW -eq 2 ]; then
    set -ex
    helm show readme $C
    { set +ex; } 2>/dev/null
  elif [ $CSHOW -eq 3 ]; then
    set -ex
    helm show values $C
    { set +ex; } 2>/dev/null
  fi
fi

#
# stage: APP-DIFF
#
if [ $ADIFF -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-DIFF"

  set -ex
  helm diff upgrade $A $C --version=$V -n $N --install --debug "${OPTS[@]}" "${OPTS2[@]}"
  { set +ex; } 2>/dev/null
fi

#
# stage: APP-INIT
#
if [ $AINIT -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-INIT (EVAL=$EVAL)"

  for cmd in "${INIT[@]}"; do
    if [ $EVAL -eq 0 ]; then
      echo $cmd
    else
      set -ex
      eval $cmd
      { set +ex; } 2>/dev/null
    fi
  done
fi

#
# stage: APP-INSTALL-UPDATE
#
if [ $AINSTALL -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-INSTALL-UPDATE"

  if [ $EVAL -eq 0 ]; then
    O="-i --create-namespace --wait --debug --dry-run"
  else
    O="-i --create-namespace --wait --debug"
  fi

  set -ex
  helm upgrade $A $C --version=$V -n $N $O "${OPTS[@]}" "${OPTS2[@]}"
  { set +ex; } 2>/dev/null
fi

#
# stage: APP-UNINSTALL
#
if [ $AUNINSTALL -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-UNINSTALL"

  if [ $EVAL -eq 0 ]; then
    O="--wait --debug --dry-run"
  else
    O="--wait --debug"
  fi

  set -ex
  helm uninstall $A -n $N $O
  { set +ex; } 2>/dev/null
fi

#
# stage: APP-LIST
#
if [ $ALIST -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-LIST"

  set -ex
  helm list -A
  { set +ex; } 2>/dev/null
fi

#
# stage: APP-HISTORY
#
if [ $AHISTORY -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-HISTORY"

  set -ex
  helm history $A -n $N
  { set +ex; } 2>/dev/null
fi

#
# stage: APP-MANIFEST
#
if [ $AMANIFEST -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-MANIFEST"

  set -ex
  helm get manifest $A -n $N
  { set +ex; } 2>/dev/null
fi

#
# stage: APP-CHART
#
if [ $ACHART -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-CHART"

  (
  echo App Nspace Chart Ver
  for f in $(ls -A $EDIR); do
    (
      unset N
      unset C
      unset V
      . $EDIR/$f
      [[ "$N" = "" ]] && N="-"
      [[ "$C" = "" ]] && C="-"
      [[ "$V" = "" ]] && V="-"
      echo $(basename $f) $N $C $V
    )
  done
  ) | column -t
fi

#
# stage: APP-LOG
#
if [ $ALOG -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: APP-LOG"

  set -ex
  kubectl logs -l app.kubernetes.io/instance=$A --all-containers=true -n $N -f --tail=-1
  { set +ex; } 2>/dev/null
fi

#
# stage: RES-ROLLOUT-RESTART
#
if [ $RRESTART -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: RES-ROLLOUT-RESTART"

  set -ex
  kubectl rollout restart $T/$A -n $N
  { set +ex; } 2>/dev/null
fi

#
# stage: RES-ROLLOUT-HISTORY
#
if [ $RHISTORY -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: RES-ROLLOUT-HISTORY"

  set -ex
  kubectl rollout history $T/$A -n $N
  { set +ex; } 2>/dev/null
fi

#
# stage: RES-ROLLOUT-STATUS
#
if [ $RSTATUS -eq 1 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: RES-ROLLOUT-STATUS"

  set -ex
  kubectl rollout status $T/$A -n $N
  { set +ex; } 2>/dev/null
fi

#
# stage: RES-SCALE
#
if [ "$RSCALE" != "" ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: RES-SCALE"

  set -ex
  kubectl scale --replicas=$RSCALE $T/$A -n $N
  { set +ex; } 2>/dev/null
fi

#
# stage: SPOOLER-LOAD
#
if [ $SLOAD -ne 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: SPOOLER-LOAD"

  if [ ! -d $SDIR ]; then
    echo "$ID: error: no spooler dir: $SDIR"
    exit 1
  fi

  if [ "$CM_HOST" = "" ]; then
    echo error: require CM_HOST
    exit 1
  fi

  set -ex
  cd $SDIR
  tree --noreport -F -h -C -L 1 $SDIR
  { set +ex; } 2>/dev/null
  echo

  ls *.tgz 2>/dev/null | sort | \
  while read I; do
    set -ex
    curl -sk --netrc-file ${CM_AUTH} --data-binary "@$I" ${CM_HOST}/api/charts?force | jq
    { set +ex; } 2>/dev/null
    if [ -d archive ]; then
      set -ex
      mv -fv $I archive/
      { set +ex; } 2>/dev/null
    fi
    echo
  done
fi

#
# stage: SPOOLER-LIST
#
if [ $SLIST -ne 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: SPOOLER-LIST"

  if [ ! -d $SDIR ]; then
    echo "$ID: error: no spooler dir: $SDIR"
    exit 1
  fi

  set -ex
  cd $SDIR
  tree --noreport -F -h -C -L 1 $SDIR
  { set +ex; } 2>/dev/null
fi

#
# stage: BACKUP
#
if [ $BACKUP -ne 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: BACKUP"

  if [ ! -d $DDIR ]; then
    set -x
    mkdir -pv $DDIR
    { set +x; } 2>/dev/null
  fi

  F=${DDIR}/hman-$(hostname -s)-$(date "+%Y%m%d%H%M").tar

  set -x
  cd /usr/local
  tar cf $F etc/hman* bin/hman*
  gzip -f $F
  { set +x; } 2>/dev/null
fi

#
# stage: BACKUP-LIST
#
if [ $BACKUP_LIST -ne 0 ]; then
  (( $s != 0 )) && echo; ((++s))
  echo "$ID: stage: BACKUP-LIST"

  set -x
  tree --noreport -F -h -C -L 1 ${DDIR}
  { set +x; } 2>/dev/null
fi
