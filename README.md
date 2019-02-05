
# cheaplogger



cheaplogger is a cheap and simple logger that is easy for everyone to use.  
Its learning cost is almost exactly zero.   



## Description
cheaplogger is able to output the following logs.  

    format1:
    [yyyy/mm/dd hh:MM:ss][hostname][log_level][user:process_id] ...  
    
    example (format1):
    [2019/02/03 09:00:00][hostname][INFO][inut:1230] ...  
    [2019/02/03 09:00:00][hostname][ERROR][inut:1230] ...  
    
    
    format2:
    [yyyy/mm/dd hh:MM:ss][hostname][log_level][log_code][user:process_id] ...  

    example (format2):   
    [2019/02/03 09:00:00][hostname][INFO][I0001][inut:1230] ...  
    [2019/02/03 09:00:00][hostname][ERROR][E0001][inut:1230] ...  



## Requirement
bash  



## Installation
create cheap.repo  

    vi /etc/yum.repos.d/cheap.repo

   cheap.repo

    [repos.cheaprepo]
    name=CentOS-$releaserver - cheaprepo
    baseurl=https://inut.github.io/cheaplogger
    enabled=1
    gpgcheck=0
    
start to install  

    yum -y install cheap_logger



## Usage
    . /usr/bin/cheaplogger.sh
    
    # In case thst FILE_ONLY equals 1, logs are written to a log file.
    # In case thst FILE_ONLY doesn't equal 1, logs are written to a log file and standard output.
    
    # In case that NOT_NEED_LOG_CODE (cheap.conf) is 0,
    # cheaplogger outputs logs without log codes (format1).
    # It's usage is as follows.
    # 1. execute a command and output its log
    exec_log "mkdir test"
    
    # 2. output info log
    info_log "something"
    
    # 3. output err log
    err_log "something"
    
    
    # In case that NOT_NEED_LOG_CODE (cheap.conf) is except 0,  
    # cheaplogger outputs logs with log codes (format2).
    # It's usage is as follows.
    # 1. execute a command and output its log
    exec_log "mkdir test" 0001
    
    # 2. output a info log
    exec_log "mkdir test" 0002
    
    # 3. output a error log
    exec_log "mkdir test" 0003
    
    



## Config file
cheaplogger has a config file. It's cheap.conf like the following file.

    #----------------------------------------------
    # 0: write to a file and standard output.
    # except 0: write to a file.
    #----------------------------------------------
    FILE_ONLY=1

    #----------------------------------------------
    # 0: log_code is outputted.
    # except 0: log_code is not outputted.
    #----------------------------------------------
    NOT_NEED_LOG_CODE=1
    
    #----------------------------------------------
    # log_level (error)
    # this is outputted as follows.
    # [...][ERROR][...] ...
    #----------------------------------------------
    ERR_STR=ERROR
    
    #----------------------------------------------
    # log_level (info)
    # this is outputted as follows.
    # [...][INFO][...] ...
    #----------------------------------------------
    INFO_STR=INFO
    
    #----------------------------------------------
    # log_file_path
    #----------------------------------------------
    CHEAP_LOG_FILE_PATH=/tmp/inut/sample.log
    
    

## Licence
This software is released under the MIT License.  
https://github.com/InuT/cheaplogger/blob/master/LICENSE

