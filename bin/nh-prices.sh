#!/bin/bash

# price tables follow branch/version in git so as to keep it simple
# this version 3.6.x+
# todo: move base to same lvl as sell + buy
 
bprice=-1
sprice=-1
cha=-1
namesOnly=1
jqArgs=()
jqFlat=0
jqRaw=1
minify=1

iclass=""
iclassFilter=""

tfile="$( dirname ${0} )/tables.yml"

debug() {
  {
  echo "b: ${bprice}"
  echo "s: ${sprice}"
  echo "c: ${cha}"
  echo "i: ${iclass}"
  } >&2
}

# used in call to jq to remove possible items from the item class name lists
iclass_filter() {

  # if already in '["foo","bar"]' format
  # passthru. otherwise: add some '[""]'
  # basic check; 'cos regexes ;)
  if [[ "${1}" =~ \[.*\] ]]
  then
    echo "${1}"
  else
    echo "[${1}]" | sed -e 's/^\[/\["/' -e 's/,/","/g' -e 's/\]$/"]/'
  fi

}

index=
OPTIND=1 OPTARG="" OPTERR=0
while getopts 'Cb:c:f:i:I:s:mnrj' flag
do
  case "${flag}" in
    C) yq -rc '.classes | keys[]' "${tfile}"; exit 0;;
    b) bprice=${OPTARG};;
    c) cha=${OPTARG};;
    i) iclass="\"${OPTARG}\"";;
    I) index=${OPTARG};;
    f) iclassFilter="$( iclass_filter ${OPTARG} )";;
    j) jqArgs+=( -j ); jqFlat=1;;
    r) jqArgs+=( -r ); jqRaw=0;;
    n) namesOnly=0;; 
    m) minify=0;;
    s) sprice=${OPTARG};;
  esac
done
shift $(( ${OPTIND} - 1 ))

if [[ -z "${iclass}" ]]
then
  echo "You forgot to tell me what item class you're trying to identify" >&2
  echo "-i <class>" >&2
  exit 2
fi

if [[ ${sprice} -gt 1 && ${bprice} -gt 1 ]]
then
  echo "You should only specify a buy- /or/ a sell-price; not both" >&2
  exit 3
fi

yqOutFilter=""
if [[ ${namesOnly} -eq 0 ]]
then
  if [[ ${jqRaw} -eq 0 ]]
  then
    yqOutFilter="| .names[]"
  else
    yqOutFilter="| .names"
  fi
fi

yqFilter=".classes[${iclass}][] | { sell, names }"

if [[ ${cha} -gt 0 ]]
then


  if [[ ${sprice} -lt 0 && ${bprice} -lt 0 ]]
  then
    yqFilter="
      (.charisma[] | select( ${cha} >= .minimum and ${cha} <= .maximum ).index ) as \$cind
        | .classes[${iclass}][]
        | { names, prices: .buy.cha[\$cind] }"
  else
      yqFilter="
      (.charisma[] | select( ${cha} >= .minimum and ${cha} <= .maximum ).index ) as \$cind |
        ( .classes[${iclass}][]
            | select( .buy.cha[\$cind]
            | contains([${bprice}]) )
        ) | { names, pindex: ( .buy.cha[\$cind] | index(${bprice}) ), prices: .buy.cha[\$cind] }"
    fi


else

  # if buy price is specified then need charisma stat!
  if [[ ${bprice} -gt 0 ]]
  then
    echo "If your using buy price, you also need to specify how charming you are! (need \"cha\" stat)" >&2
    exit 1
  fi

  if [[ ${sprice} -gt 1 ]]
  then
    yqFilter=".classes[${iclass}][] | select(.sell | contains([${sprice}]) ) | { names, prices: .sell }"
  fi

fi

sedcmd=
[[ ${minify} -eq 0 ]] && sedcmd=( 
  sed -r -e 's/_from_shape_changers/_fr_shp_chng/g' 
         -e 's/ability/ablty/g'
         -e 's/accuracy/acc/g' 
         -e 's/action/actn/g' 
         -e 's/adornment/adrn/g' 
         -e 's/aggravate/agg/g' 
         -e 's/amnesia/amns/g' 
         -e 's/armor/arm/g' 
         -e 's/ation//g' 
         -e 's/blindness/blind/g'
         -e 's/cancellation/cancel/'
         -e 's/charging/chrg/g'
         -e 's/conflict/cnflct/g' 
         -e 's/confus(e|ion)/conf/g'
         -e 's/constitution/co/g' 
         -e 's/control/ctrl/g' 
         -e 's/create/creat/g'
         -e 's/curse/curs/g'
         -e 's/damage/dmg/g' 
         -e 's/destroy/dst/g' 
         -e 's/detect_/dtct_/g'
         -e 's/detection/dtec/g'
         -e 's/digestion/dgstn/g' 
         -e 's/enchant/ench/g'
         -e 's/energy/nrgy/g'
         -e 's/enlightenment/enlgt/g'
         -e 's/familiar/faml/g'
         -e 's/finger_of_death/f_o_d/g'
         -e 's/force/forç/g'
         -e 's/fruit/frt/'
         -e 's/genocide/geno/g'
         -e 's/hallucin(ation)*/hallu/'
         -e 's/healing/heal/g'
         -e 's/hunger/hungr/g' 
         -e 's/identify/ident/g'
         -e 's/increase/inc/g' 
         -e 's/invisibility/invis/g' 
         -e 's/invisible/invis/g' 
         -e 's/juice/juc/g'
         -e 's/jumping/jump/g'
         -e 's/levitation/levi/g' 
         -e 's/magic/mag/g'
         -e 's/mapping/map/g'
         -e 's/missile/msl/g'
         -e 's/monster/mnstr/g' 
         -e 's/object/obj/g'
         -e 's/poison/poisn/g' 
         -e 's/polymorph/poly/g' 
         -e 's/protection/prot/g' 
         -e 's/punishment/punish/g'
         -e 's/regeneration/regen/g' 
         -e 's/remove/rem/g'
         -e 's/resistance/rsist/g' 
         -e 's/restore/rstr/g'
         -e 's/searching/srch/g' 
         -e 's/sickness/sick/g'
         -e 's/sleeping/sleep/g'
         -e 's/stealth/stlth/g' 
         -e 's/stinking/stnk/g'
         -e 's/strength/str/g' 
         -e 's/sustain/sust/g' 
         -e 's/teleport/tport/g' 
         -e 's/undead/und/g'
         -e 's/unholy/un/g'
         -e 's/warning/warn/g' 
         -e 's/weapon/weap/g'
         -e 's/wizard/wiz/g'
  ) || sedcmd=( cat )

yq ${jqArgs[@]} -c "${yqFilter} ${yqOutFilter}" "${tfile}" | ${sedcmd[@]}
