#!/bin/bash

clean_download_dir=0

while getopts ":a:k:f:d:c" opt; do
  case $opt in
    a) quip_api_url="$OPTARG"
    ;;
    k) quip_api_key="$OPTARG"
    ;;
    f) folder_list="$OPTARG"
    ;;
    d) download_dir="$OPTARG"
    ;;
    c) clean_download_dir=1
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# Print required arguments if any of the arguments are missing
if [ -z "$quip_api_url" ] || [ -z "$quip_api_key" ] || [ -z "$folder_list" ] || [ -z "$download_dir" ]; then
  echo "Usage: $0 -a <quip_api_url> -k <quip_api_key> -f <folder_list> -d <download_dir> -c"
  exit 1
fi

# Get the full path of the current directory
plugin_dir=$(pwd)

if [[ "$clean_download_dir" -eq 1 ]]; then
  echo "Deleting all files in $download_dir"
  rm -rf "$download_dir/*"
fi

# Download Quip documents to the $download_dir directory
npx "dastra/quip-export" -t "$quip_api_key" -d "$download_dir" --embedded-images --embedded-styles --docx \
  --api-url "$quip_api_url" --folders "$folder_list"

cd "$download_dir" || ( echo "$download_dir does not exist" && exit 1 )

tempfile=$(mktemp)
find . -type f -name "*.docx" -exec ls {} \; > tempfile
while read line; do
    echo "$line"
    cd "$download_dir"

    # Extract the file path from $line
    file_path=$(dirname "$line")
    # Extract the filename from $line
    filename=$(basename "$line")

    cd "$file_path" || ( echo "$file_path does not exist" && exit 1)

    mkdir "$filename".tmp
    mv "$filename" "$filename".tmp/
    cd "$filename".tmp/
    unzip -q "$filename"
    cd word

    # In the docx file, use perl to replace '<w:name w:val="code"/>' with '<w:name w:val="Source Code"/>' so that the
    # pandoc converter to markdown picks up code blocks
    perl -p -i -e 's/<w:name w:val="code"\/>/<w:name w:val="Source Code"\/>/g' styles.xml

    cd ../
    rm "$filename"
    zip -q -r ../"$filename" *
    cd ../
    rm -rf "$filename".tmp/

    # Remove the file extension file name and append md
    md_filename=$(echo "$filename" | sed 's/\.docx/.md/g')

    # markdown_mmd / gfm works best
    # markdown, markdown-raw_html, markdown_phpextra, commonmark not working
    echo "In $file_path. Converting $filename to $md_filename"
    pandoc "$filename" -f docx-styles -t markdown_mmd -s -o "$md_filename" --extract-media=./ --wrap=preserve \
      --lua-filter="$plugin_dir"/CodeBlockFilter.lua

    # Remove all blank lines where they are followed by spaces and then a dash or asterisk
    perl -i -pe 'BEGIN{undef $/;} s/\n(\n[\t\s]*)[-\*][\t\s]+/$1\* /smg' "$md_filename"

    # Convert images from html to markdown
    perl -i -pe 'BEGIN{undef $/;} s/<img src="([^"]+)" [^\/]+ \/>/![]($1)/smg' "$md_filename"

    # Remove the temporary docx file
    rm "$filename"
done < tempfile

rm "$download_dir"/tempfile
mv "$download_dir"/quip-export/* "$download_dir"/
rmdir "$download_dir"/quip-export
rm "$download_dir"/export.log
