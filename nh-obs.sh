#!/bin/bash

nhuser="fubinax"

build=0 # enum
run=0 # bool

hdir_short="";

usg="
  $( basename ${0} ) [-b] -d <hackdir> [-u <name>]
"
if [[ ${#} -eq 0 ]]
then
  echo "${usg}" >&2
  exit 0
fi

OPTIND=1 OPTARG="" OPTERR=0
while getopts 'bd:u:' flag
do
  case "${flag}" in
    b)  build=2;;
    d)  hdir_short="${OPTARG}";;
    u)  nhuser="${OPTARG}";;
  esac
done
# getopts wierdness!
shift $(( ${OPTIND} - 2 ))

if [[ -z "${hdir_short}" ]]
then
  echo 'You must...dungeon location'
  exit 1
fi
hdir="$( realpath "${hdir_short}" )"

function build(){
  local hdir="${1}"
  scr="read an uncursed scroll of create directory"
  case ${build} in
  1)
    echo -e "\nIt's too dark to find the hackdir! \"${hdir}\"" >&2
    read -p "${scr}? [Y/n]" ans
    ans="${ans:-Y}"
    if [[ ${ans} != "Y" ]]
    then
      echo "...you decide not to risk it." >&2
      exit 1
    fi;;
  2) :;;
  *) return 0;;
  esac

  echo "You ${scr}." >&2
  hdir="$( realpath -m "${hdir}" )"

  # make base64?
  mkdir -p "${hdir}"/{bones,save,level,lock,trouble}
  cp "$( realpath $( dirname ${0} ) )"/dot-nethackrc "${hdir}"/
  cp /var/games/nethack/{nhdat,symbols,sysconf,license} "${hdir}"/

  cd "${hdir}"
  touch perm logfile xlogfile
  echo "Now re-cast this script to enter the maze." >&2
  run=1
}

if [[ ${build} -eq 0 && ! -d "${hdir}" ]]
then
  build=1
fi

export NETHACKOPTIONS=@"${hdir}/dot-nethackrc" \
       NETHACKDIR="${hdir}" \
       LEVELDIR="${hdir}/level" \
       SAVEDIR="${hdir}/save" \
       BONESDIR="${hdir}/bones" \
       LOCKDIR="${hdir}/lock" \
       TROUBLEDIR="${hdir}/trouble"

if [[ ${build} -gt 0 ]]
then
  build "${hdir_short}"
fi

if [[ ${run} -eq 0 ]]
then
  nethack -u "${nhuser}" "${@}"
fi
