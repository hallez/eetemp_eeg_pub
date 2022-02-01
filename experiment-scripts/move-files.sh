#!/bin/bash
# based on: http://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable

input_folder="/Users/hrzucker/Dropbox/work/ranganath_lab/data/eetemp/stimuli/BOSS-resized/export"
output_folder="/Users/hrzucker/Dropbox/work/ranganath_lab/data/eetemp/stimuli/BOSS-stimuli-1000px" 

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Copying file: $line"
    cp $input_folder/$line.png $output_folder/$line.png
done < "$1"
