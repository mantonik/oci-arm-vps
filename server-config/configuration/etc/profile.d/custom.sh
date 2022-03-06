#Custom Profile file
# 1.0 initial version 
# 1.1 add alias
###################
version=1.2

export PS1='\u@\h:\w\n#'
export PATH=$PATH:$HOME/bin:/home/opc/bin
export http_proxy=http://10.10.1.11:3128/
export https_proxy=http://10.10.1.11:3128/
export no_proxy=localhost,127.0.0.1,10.10.1.11,10.10.1.12,10.10.1.13,10.10.1.14,169.254.169.254
# 169.254.169.254 - Oracle cloud server for agent communication 
#
#display umask values
#umask -S
#umask=022 #default
umask 0027

#Aliases
alias rsync_server="sudo /home/opc/bin/rsync_server.sh"
alias restart_services="sudo /home/opc/bin/restart_services.sh now"
alias set_permissions="sudo /home/opc/bin/set_permissions.sh"
alias update_root_cron="sudo /home/opc/bin/update_root_cron.sh"

# END

