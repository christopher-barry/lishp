#!/bin/bash

# If this file has already been sourced, just return
[ ${SPECIALFORMS_SH+true} ] && return
declare -g SPECIALFORMS_SH=true

. ${BASH_SOURCE%/*}/common.sh
. ${BASH_SOURCE%/*}/variables.sh
. ${BASH_SOURCE%/*}/variables.linkedlist.sh
. ${BASH_SOURCE%/*}/evaluator.sh

variable::type::define SpecialForm Callable

#
# ============================================================
#
# Special Forms

#
# LET*
#
# let* is similar to let, but the bindings are performed sequentially from left to
# right, and the region of a binding is that part of the let* expression to the right
# of the binding. Thus the second binding is done in an environment in which the first
# binding is visible, and so on.
#
# (let* ((variable1 init1)
#        (variable2 init2)
#        ...
#        (variableN initN))
#     expression
#     expression ...)
#
function evaluator::specialforms::letstar() {
    stderr "Not implemented yet"
    exit 1
}

#
# DEFINE
#
# Creates a new variable assigned to a value
#
function evaluator::specialforms::define() {
    stderr "Not implemented yet"
    exit 1
}

#
# SET!
#
# Sets a variable to a value
#
function evaluator::specialforms::set() {
    stderr "Not implemented yet"
    exit 1
}

#
# PROGN
#
# The expressions are evaluated sequentially from left to right, and the value
# of the last expression is returned. This expression type is used to sequence
# side effects such as input and output. 
#
function evaluator::specialforms::begin() {
    stderr "Not implemented yet"
    exit 1
}

# 
# ======================================================
if [ $0 != $BASH_SOURCE ]; then
    return
fi




assert::report

if [ ${1+isset} ] && [ "$1" == "debug" ]; then 
    variable::printMetadata
fi

