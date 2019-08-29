#!/bin/bash
# http://www.karimsultan.com/live/?p=10136
 
case $THEME in
    plain)
        bold=$''  # Style Bold
        dim=$''   # Style Dim
        bold=$''  # Style Bold
        reset=$'' # Reset
    ;;
    *)
        bold=$'\e[1m'  # Style Bold
        dim=$'\e[2m'   # Style Dim
        bold=$'\e[1m'  # Style Bold
        reset=$'\e[0m' # Reset
    ;;
esac


