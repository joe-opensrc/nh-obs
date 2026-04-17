#!/bin/bash 

nhuser="fubinax"

build=0 # enum
rcfile=""
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
while getopts 'bc:d:u:' flag
do
  case "${flag}" in
    b)  build=2;;
    c)  rcfile=${OPTARG};;
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
  cp "$( dirname ${0} )"/../conf/{dot-nethackrc,wizkit.txt} "${hdir}"/ # &>/dev/null
  cp /var/games/nethack/{nhdat,symbols,sysconf,license} "${hdir}"/

  cd "${hdir}"
  touch perm logfile xlogfile
  # yolo enable wizard-mode
  sed -i -e "s/^WIZARDS=\(.*\)/WIZARDS=\1 ${nhuser}/" "${hdir}"/sysconf
  echo "Now re-cast this script to enter the maze." >&2
  nhrcf="${hdir}/dot-nethackrc"
  [[ ! -r "${nhrcf}" ]] && echo "You might also want to create the config scroll: ${nhrcf}"
  run=1
}

if [[ ${build} -eq 0 && ! -d "${hdir}" ]]
then
  build=1
fi

if [[ -n "${rcfile}" ]]
then
  nhrcf="${rcfile}"
else
  nhrcf="${hdir}/dot-nethackrc"
fi

export NETHACKOPTIONS=@"${nhrcf}" \
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
  # r=""
  # if [[ -e ${hdir}/saves/*.gz ]]
  # then 
    # re="(re-)e"
  # else
    # re="E"
  # fi
  # echo -e "${re}nter the dungeons at: ${hdir_short}?\n(ctrl-c to abort)"
  # read
  nethack -u "${nhuser}" "${@}"
fi
