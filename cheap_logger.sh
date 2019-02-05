#!/bin/bash

. $(cd $(dirname $BASH_SOURCE); pwd)/cheap.conf


#-----------------------------------------------------------------------------------
# Simple writter.
# return:
#   success: 0
#   error: except 0
#-----------------------------------------------------------------------------------
function writter(){
  if [ $FILE_ONLY -eq 0 ]; then
    tee -a ${CHEAP_LOG_FILE_PATH}
  else
    cat >> ${CHEAP_LOG_FILE_PATH}
  fi

  return
}


#-----------------------------------------------------------------------------------
# This function writes logs.
# args:
#   $1: log_level
#   $2: message
#   $3: log_code   <- when $NOT_NEED_LOG_CODE equals 0, log_code is required
# return:
#   success: 0
#   error: except 0
#-----------------------------------------------------------------------------------
function write_log() {
  if [ "$NOT_NEED_LOG_CODE" = 0 ]; then
    local prefix=${1:0:1}
    echo "[$(date +%Y/%m/%d" "%H:%M:%S)]["$(hostname)"][$1][${prefix}${3}][$(whoami):$BASHPID] $2" | writter
  else
    echo "[$(date +%Y/%m/%d" "%H:%M:%S)]["$(hostname)"][$1][$(whoami):$BASHPID] $2" | writter
  fi

  return
}


#-----------------------------------------------------------------------------------
# This function outputs info level logs.
# args:
#   $1: message
#   $2: log_code   <- when $NOT_NEED_LOG_CODE equals 0, log_code is required
# return:
#   success: 0
#   error: except 0
# output logF
#   [yyyy/mm/dd hh:MM:ss][hostname][INFO][<user>:<process_id>] <message>
#   [yyyy/mm/dd hh:MM:ss][hostname][INFO][I<log_code>][<user>:<process_id>] <message>   <- when $NOT_NEED_LOG_CODE equals 0
#-----------------------------------------------------------------------------------
function info_log() {
  check_params "$@"

  if [ $? -ne 0 ]; then
    return 1
  fi

  write_log $INFO_STR "$@"

  return 0
}


#-----------------------------------------------------------------------------------
# This function outputs error level logs.
# args:
#   $1: message
#   $2: log_code   <- when $NOT_NEED_LOG_CODE equals 0, log_code is required
# return:
#   success: 0
#   error: except 0
# output logF
#   [yyyy/mm/dd hh:MM:ss][hostname][ERROR][<user>:<process_id>] <message>
#   [yyyy/mm/dd hh:MM:ss][hostname][ERROR][E<log_code>][<user>:<process_id>] <message>   <- when $NOT_NEED_LOG_CODE equals 0
#-----------------------------------------------------------------------------------
function err_log() {
  check_params "$@"

  if [ $? -ne 0 ]; then
    return 1
  fi

  write_log $ERR_STR "$@"

  return
}


#-----------------------------------------------------------------------------------
# This function outputs info or error level logs that
# are created by executing commands.
# args:
#   $1: log_level
#   $2: log_command
#   $3: log_code   <- when $NOT_NEED_LOG_CODE equals 0, log_code is required
# return:
#   success: 0
#   error: except 0
#-----------------------------------------------------------------------------------
function write_execlog() {
    if [ "$NOT_NEED_LOG_CODE" = 0 ]; then
      local prefix=${1:0:1}
      gawk '{ print strftime("[%Y/%m/%d %H:%M:%S]["$(hostname)"]['$1']['${prefix}''${3}']['$(whoami)':'$BASHPID']"), $0; fflush() }' | writter
    else
      gawk '{ print strftime("[%Y/%m/%d %H:%M:%S]["$(hostname)"]['$1']['$(whoami)':'$BASHPID']"), $0; fflush() }' | writter
    fi

    return
}


#-----------------------------------------------------------------------------------
# This function executes a command and writes logs.
# args:
#   $1: command
#   $2: log_code   <- when $NOT_NEED_LOG_CODE equals 0, log_code is required
# return:
#   success: 0
#   error: except 0
# output logF
#   when execution result status of command, that is '$1', is success:
#     [yyyy/mm/dd hh:MM:ss][hostname][INFO][<user>:<process_id>] <message>
#     [yyyy/mm/dd hh:MM:ss][hostname][INFO][I<log_code>][<user>:<process_id>] <message>   <- when $NOT_NEED_LOG_CODE equals 0
#   when execution result status of command, that is '$1', is error:
#     [yyyy/mm/dd hh:MM:ss][hostname][ERROR][<user>:<process_id>] <message>
#     [yyyy/mm/dd hh:MM:ss][hostname][ERROR][E<log_code>][<user>:<process_id>] <message>   <- when $NOT_NEED_LOG_CODE equals 0
#-----------------------------------------------------------------------------------
function exec_log() {
  check_params "$@"

  if [ $? -ne 0 ]; then
    return 1
  fi

  local pid=$BASHPID
  log_str=$(${1} 2>&1)
  local check_err=$?

  if [ $check_err -ne 0 ];then
    echo $log_str | write_execlog $ERR_STR "$@"
  else
    echo $log_str | write_execlog $INFO_STR "$@"
  fi
  local check_err_logging=$?

  return $(($check_err + $check_err_logging))
}


#-----------------------------------------------------------------------------------
# This function checks params.
# args:
#   $1: message
#   $2: log_code   <- when $NOT_NEED_LOG_CODE equals 0, log_code is required
# return:
#   success: 0
#   error: 1
#-----------------------------------------------------------------------------------
function check_params() {
  if [ "$NOT_NEED_LOG_CODE" = 0 ]; then
    sub_check_params ${FUNCNAME[1]} $# $2
  else
    sub_check_params_without_log_code ${FUNCNAME[1]} "$#"
  fi

  local check_err=$?

  return $check_err
}


#-----------------------------------------------------------------------------------
# This function checks params that don't include 'log_code'.
# args:
#   $1: func_name (caller)
#   $2: param_num
# return:
#   success: 0
#   error: 1
#-----------------------------------------------------------------------------------
function sub_check_params_without_log_code() {
  if [ $2 -ne 1 ]; then
    if [ $1 == "exec_log" ]; then
      echo "[$(date +%Y/%m/%d" "%H:%M:%S)]["$(hostname)"][${ERR_STR}][$(whoami):$BASHPID] Usage: $1 <command>" | writter
    else
      echo "[$(date +%Y/%m/%d" "%H:%M:%S)]["$(hostname)"][${ERR_STR}][$(whoami):$BASHPID] Usage: $1 <message>" | writter
    fi

    return 1
  fi

  return 0
}


#-----------------------------------------------------------------------------------
# This function checks params that include 'log_code'.
# args:
#   $1: func_name (caller)
#   $2: param_num
# return:
#   success: 0
#   error: 1
#-----------------------------------------------------------------------------------
function sub_check_params() {
  if [ $2 -ne 2 ]; then
    if [ $1 == "exec_log" ]; then
      echo "[$(date +%Y/%m/%d" "%H:%M:%S)]["$(hostname)"][${ERR_STR}][$(whoami):$BASHPID] Usage: $1 <\"command\"> <log_code>" | writter
    else
      echo "[$(date +%Y/%m/%d" "%H:%M:%S)]["$(hostname)"][${ERR_STR}][$(whoami):$BASHPID] Usage: $1 <\"message\"> <log_code>" | writter
    fi
    return 1
  fi

  return 0
}
