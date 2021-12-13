#!/bin/bash
# Simple backup script
# Tamashi ~ 11/11/21

  DATE=$(date +%y%m%d_%H%M%S)
  Destination=$1
  Target=$2
  echo ${Target}
  Here=$(pwd)/"forum_backup_${DATE}.tar.gz"
  tar cvzf "forum_backup_${DATE}.tar.gz" ${Target}
  Qty=10
  rsync -av --remove-source-files ${Here} ${Destination}
  ls -tp "${Destination}" | grep -v '/$' | tail -n +${Qty} | xargs -I {} rm -- ${Destination}/{}

