###  # This is my function to backup folders on my Arch Linux system
###  # to my Raspberry Pi NAS.
###  function my_rsync() {
###          if [ $# -lt 2 ] || [ $# -gt 3 ]; then
###                  echo "Usage: my_rsync [--dry-run] <srcdir> <dstdir>"
###                  return 1
###          fi
###  
###          if [ $# = 3 ]; then
###                  OPTS=(--dry-run)
###                  SRCDIR="$2"
###                  DSTDIR="$3"
###          else
###                  OPTS=()
###                  SRCDIR="$1"
###                  DSTDIR="$2"
###          fi
###  
###          if [ ! -d "$SRCDIR" ]; then
###                  echo "$SRCDIR doesn't exist"
###                  return 2
###          fi
###  
###          OPTS+=( --update 
###                  --archive 
###                  --recursive 
###                  --delete 
###                  --times 
###                  --exclude='$RECYCLE.BIN' 
###                  --exclude='.Trash-1000' 
###                  '--exclude=System Volume Information' 
###                  --chown=root:root 
###                  --human-readable 
###                  --verbose 
###                  --progress 
###                  --stats)
###  
###          rsync $OPTS "$SRCDIR/" "$DSTDIR"
###  
###          if [ $? = 0 ]; then
###                  echo "rsync completed successfully!"
###          else
###                  echo "rsync ERROR!"
###          fi
###  }
###  
###  
###  # This backs up all folders on my Arch/Windows system to my Raspberry Pi NAS.
###  function my_backup() {
###          if [ $# != 1 ]; then
###                  echo "Usage: Backup <Raspberry Pi IP Address>"
###                  return 1
###          fi
###  
###          IPADDR="$1"
###          WINHOME="/mnt/cdrive/Users/ashish"
###          ARCHHOME="/home/ashish"
###          NASHOME="pi@${IPADDR}:/mnt/Backup/"
###          SRCFOLDERS=("$WINHOME/Downloads" "$WINHOME/Documents" "$ARCHHOME/Ebooks" "$ARCHHOME/Music")
###          DSTFOLDERS=(Downloads Documents eBooks Music)
###  
###          if [ ! -d "$WINHOME" ]; then
###              echo "Please mount the Windows partition to /mnt/cdrive."
###              return 1
###          fi
###                 
###      
###          i=0
###          while (( i++ < $#SRCFOLDERS )); do 
###                  my_rsync --dry-run $SRCFOLDERS[i] "${NASHOME}$DSTFOLDERS[i]"
###                  echo "Sync ${SRCFOLDERS[i]}? (yes/no):"
###                  read ANSWER
###                  if [[ $ANSWER = (#i)"yes" ]]; then
###                          my_rsync $SRCFOLDERS[i] "${NASHOME}$DSTFOLDERS[i]"
###                          echo "Press <ENTER> to continue"
###                          read
###                  fi
###          done
###  
###          echo "*** DONE BACKUP ***"
###          return 0
###  }
        
# My NEW backup function
function backup() {
        find /var/log/ashish -ctime +1 -delete

        BACKUP_LOG="/var/log/ashish/backup-$(date +"%H:%M:%S").log"
        touch $BACKUP_LOG

        OPTIONS=(--human-readable --stats --progress --archive --update --delete --exclude-from=/home/ashish/rsyncd/rsyncd.exclude --log-file=$BACKUP_LOG)

        echo "Please attach external Crucial SSD and mount it to /Backup."
        read -k 1 "DUMMY?Press any key when ready."
        echo

        echo
        sudo rsync --dry-run $OPTIONS /etc/ /Backup/etc
        echo

        read -k 1 "ETC?Backup /etc (y/n)?"
        if [[ $ETC = (#i)"y" ]]; then
                sudo rsync $OPTIONS /etc/ /Backup/etc
        fi

        read -k 1 "DUMMY?Press any key when ready."
        echo
        sudo rsync --dry-run $OPTIONS /home/ashish/ /Backup/asus/home/ashish

        echo
        read -k 1 "CONTINUE?Continue (y/n)?"
        if [[ $CONTINUE = (#i)"y" ]]; then
                sudo rsync $OPTIONS /home/ashish/ /Backup/asus/home/ashish
        fi
}

# Backup to Raspberry Pi or Toshiba laptop rsync daemon
# DEPRECATED!!!
#function rsync-backup() {
#        read -k 1 "DEST?Backup to Raspberry Pi (1) or Toshiba laptop (2)?"
#        if [[ $DEST = 1 ]]; then
#                DEST="rpi2";
#        else
#                DEST="toshiba";
#        fi
#        echo
#        echo
#        read -s "RSYNC_PASSWORD?Please enter rsync daemon password:"
#        echo
#        echo "$RSYNC_PASSWORD" | rsync --password-file=- --dry-run -avux --delete --human-readable --stats --progress "/etc" "rsync://ashish@$DEST:2000/etc"
#        read -k 1 "BACKUP?Backup this folder (y/n)?"
#        echo
#        if [[ $BACKUP = (#i)"y" ]]; then
#                echo "$RSYNC_PASSWORD" | rsync --password-file=- -avux --delete --human-readable --stats --progress "/etc" "rsync://ashish@$DEST:2000/etc"
#        fi
#        for d in VBox-shared sql_work python_work EBooks Downloads Documents Shared Music Google\ Drive; do
#                echo
#                echo
#                echo "##############################################################################"
#                echo "########################## $d #########################"
#                echo "##############################################################################"
#                echo
#                echo "$RSYNC_PASSWORD" | rsync --password-file=- --dry-run -avux --delete --human-readable --stats --progress "/home/ashish/$d/" "rsync://ashish@$DEST:2000/$d"
#                read -k 1 "BACKUP?Backup this folder (y/n)?"
#                echo
#                if [[ $BACKUP = (#i)"y" ]]; then
#                        echo "$RSYNC_PASSWORD" | rsync --password-file=- -avux --delete --human-readable --stats --progress "/home/ashish/$d/" "rsync://ashish@$DEST:2000/$d"
#                fi
#        done
#}

function printmenu() {
    OFS=$IFS;
    IFS=$'\n';
    i=0; 
    for d in $(rsync rsync://rpi2:2000/); do 
            ((i=$i+1)); 
            echo "$i) $d"; 
    done; 
    echo "q) quit";
    IFS=$OFS;
}
