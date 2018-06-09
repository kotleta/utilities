#! /usr/bin/env bash
# auto unrar library in catalog

for entry in ./*
do
  echo "
===$entry==="
	for entry_in in "$entry"/*
	do
		if [ -f "$entry_in" ];then
			if [[ $string = *".rar" ]]; then
				echo "$entry_in"
				unrar x -y $entry_in
				rm -f $entry_in
			fi
		fi
	done
done
exit 0;
