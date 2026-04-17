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

iclass=""

tfile="$( dirname ${0} )/tables.yml"

debug() {
  {
  echo "b: ${bprice}"
  echo "s: ${sprice}"
  echo "c: ${cha}"
  echo "i: ${iclass}"
  } >&2
}

index=
OPTIND=1 OPTARG="" OPTERR=0
while getopts 'Cb:c:i:I:s:nrj' flag
do
  case "${flag}" in
    C) yq -rc '.classes | keys[]' "${tfile}"; exit 0;;
    b) bprice=${OPTARG};;
    c) cha=${OPTARG};;
    i) iclass="\"${OPTARG}\"";;
    I) index=${OPTARG};;
    j) jqArgs+=( -j ); jqFlat=1;;
    r) jqArgs+=( -r ); jqRaw=0;;
    n) namesOnly=0;; 
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
    # yqFilter="(.charisma[] | select( ${cha} >= .minimum and ${cha} <= .maximum ).index ) as \$cind | .classes[${iclass}][] | { names, cha: \"${cha}\", prices: .buy.cha[\$cind] }"
    yqFilter="(.charisma[] | select( ${cha} >= .minimum and ${cha} <= .maximum ).index ) as \$cind | .classes[${iclass}][] | { names, prices: .buy.cha[\$cind] }"
  else
    
      yqFilter="(.charisma[] | select( ${cha} >= .minimum and ${cha} <= .maximum ).index ) as \$cind | ( .classes[${iclass}][] | select( .buy.cha[\$cind] | contains([${bprice}]) ) ) | { names, pindex: ( .buy.cha[\$cind] | index(${bprice}) ), prices: .buy.cha[\$cind] }"
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

# debug
# set -x
yq ${jqArgs[@]} -c "${yqFilter} ${yqOutFilter}" "${tfile}"
