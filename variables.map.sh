#!/bin/bash

# If this file has already been sourced, just return
[ ${VARIABLES_MAP_SH+true} ] && return
declare -g VARIABLES_MAP_SH=true

. common.sh
. logger.sh
. variables.sh
. variables.arraylist.sh

variable::type::define Map ArrayList

#
# MAP
# 
# Map commands act on a list data structure, assuming the format
#     <key token> <value token> ... <key token> <value token>
#

function variable::Map::new() {
    variable::new Map "${@}"
}


#
# containsKey_c <map token> <key>
#
function variable::Map::containsKey_c() {
    if [[ ${VARIABLES_DEBUG} == 1 ]]; then stderr "variable::Map::containsKey_c ${@}" ; fi

    declare mapToken="${1}"
    declare key="${2}"
#    stderr "Checking value for token [${mapToken}] =? [${VARIABLES_VALUES[${mapToken}]}]"
    variable::value "${mapToken}" ; declare -a items
    if [[ "${RESULT}" == "" ]]; then items=() ; else items=(${RESULT}) ; fi
#    stderr "    RESULT = [${RESULT}]"

    declare size 
    declare max_index
    declare currentKey
    (( size=${#items[@]}, max_index=size-1 ))
#    stderr "    Iterating over size=[${size}], max_index=[${max_index}]"
    declare -i i
    for ((i=0; i<=max_index; i=i+2)); do
#        stderr "        here at i=${i} / items[0]=${items[0]} / items=${items[@]}"
#        echo "        Looking up key at ${i} : [${items[${i}]}]"
        variable::value "${items[${i}]}" ; currentKey="${RESULT}"
#        echo "        Current Key [${currentKey}]"
        if [ "${currentKey}" == "${key}" ]; then
#            echo "            found it"
            return 0
        fi
    done
#    stderr "    containsKey_c returning 1"
    return 1
}

#
# get <map token> <key>
#
function variable::Map::get() {
    if [[ ${VARIABLES_DEBUG} == 1 ]]; then stderr "variable::Map::get ${@}" ; fi

    declare mapToken="${1}"
    declare key="${2}"
    declare -a items
    variable::value $mapToken
    if [[ "${RESULT}" == "" ]]; then items=() ; else items=(${RESULT}) ; fi
    #stderr "Items (${#items[@]}): ${items[@]}"
    declare size 
    declare max_index
    declare currentKey
    (( size=${#items[@]}, max_index=size-1 ))
    for ((i=0; i<=max_index; i=i+2)); do
        variable::value "${items[${i}]}" ; currentKey="${RESULT}"
        if [ "${currentKey}" == "${key}" ]; then # found it
            variable::value "${items[((${i}+1))]}" ; RESULT="${items[((${i}+1))]}"
            return 0
        fi
    done
    return 1
}

function _variable::Map::get_p() {
    if ! variable::Map::get "${@}"; then
        stderr "Map does not contain the specified key [${2}]"
        exit 1
    fi
    echo "$RESULT"
}

#
# put <map token> <key token> <value token>
#
# Returns 0 if item was found and replaced, 1 if added
#
function variable::Map::put() {
    declare mapToken="${1}"
    declare keyToken="${2}"
    declare valueToken="${3}"

    variable::value $mapToken ; declare -a items
    if [[ "${RESULT}" == "" ]]; then items=() ; else items=(${RESULT}) ; fi
    log "MAP: $(_variable::value_p $mapToken)"
    log "Adding new key/value to items [$keyToken]=[$valueToken] -> ${items[@]:+${items[@]}}"
    variable::value $keyToken   ; declare key="${RESULT}"
    variable::value $valueToken ; declare value="${RESULT}"

    declare size
    declare max_index
    declare currentKey
    (( size=${#items[@]}, max_index=size-1 ))
    for ((i=0; i<=max_index; i=i+2)); do
        variable::value ${items[${i}]} ; currentKey="${RESULT}"
        if [ "${currentKey}" == "${key}" ]; then # found it
            items[((${i}+1))]="${valueToken}"
            variable::set ${mapToken} ArrayList "${items[*]}"
            return 0
        fi
    done

    # Not found, add it to the end of the list
    items["${#items[@]}"]="${keyToken}"
    items["${#items[@]}"]="${valueToken}"
    log "Added new key/value to items [$keyToken]=[$valueToken] -> ${items[@]}"
    variable::set ${mapToken} ArrayList "${items[*]}"
    return 1
}

#
# DEBUGGING
#

function variable::Map::print() {
    declare mapToken="${1}"
    declare indent="${2}"
    
    variable::value $mapToken ; declare -a items
    if [[ "${RESULT}" == "" ]]; then items=() ; else items=(${RESULT}) ; fi

    echo "${indent}MAP [$mapToken=(${items[@]})]"

    declare size
    declare max_index
    declare currentKey
    declare currentValue 

    (( size=${#items[@]}, max_index=size-1 ))
    for ((i=0; i<=max_index; i=i+2)); do
        variable::value ${items[${i}]} ; currentKey="${RESULT}"
        variable::value ${items[((i+1))]} ; currentValue="${RESULT}"
        echo "${indent}    [${currentKey}]=[${currentValue}]"
    done
}


# ======================================================
if [ $0 != $BASH_SOURCE ]; then
    return
fi


#
# MAP tests
#
variable::Map::new ; vCode=${RESULT}
variable::new String "key one" ; key1=${RESULT}
variable::new String "value one" ; value1=${RESULT}
variable::new String "key two" ; key2=${RESULT}
variable::new String "value two" ; value2=${RESULT}

# stderr "vCode=[${vCode}] key1=[${key1}] value1=[${value1}] key2=[${key2}] value2=[${value2}] "

variable::Map::containsKey_c $vCode "no such key"
assert::equals 1 $? "containsKey false"

variable::Map::put $vCode $key1 $value1 # put "key one" "value one"
variable::Map::containsKey_c $vCode "key one"
assert::equals 0 $? "containsKey one true"
variable::Map::get "$vCode" "key one" ; variable::value "${RESULT}" \
    assert::equals "value one" "$RESULT" "get key one"

variable::Map::put $vCode $key2 $value2 # put "key two" "value two"
variable::Map::containsKey_c $vCode "key two"
assert::equals 0 $? "containsKey two true"
variable::Map::get $vCode "key two" ; variable::value "${RESULT}" \
    assert::equals "value two" "$RESULT" "get key two"

variable::Map::put $vCode $key1 $value2 # put "key one" "value two"
variable::Map::containsKey_c $vCode "key one"
assert::equals 0 $? "containsKey one replaced true"
variable::Map::get $vCode "key one" ; variable::value "${RESULT}" \
    assert::equals "value two" "$RESULT" "get key one replaced"


assert::report

if [ ${1+isset} ] && [ "$1" == "debug" ]; then 
    variable::printMetadata
fi
