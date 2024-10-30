# quip-to-obsidian

quip-export.sh works on macOS to download documents from Quip and converts them to a more Obsidian friendly version of Markdown.

## Prerequisites

```shell
brew install pandoc perl
```

## To run

There are a number of parameters you can pass to the script:

* -a - Quip API URL.  This is usually "https://platform.quip.com:443/1" unless you are using a self-hosted Quip instance
* -k - Quip API Key.  Get yours using your web browser from https://quip.com/dev/token or your self-hosted Quip instance
* -f - A comma separated list of folders you want to export.  The folder id will look like zZBaAx25FlzN and forms the first part of the Quip URL - i.e. from https://quip.com/zZBaAx25FlzN/Useful-Obsidian-Plugins the folder id is zZBaAx25FlzN.  
* -d - the absolutey path to the destination export folder.
* -c - whether to delete all files from the destination export folder before beginning the Quip export.

Example:

```
bash quip-export.sh -a https://platform.quip.com:443/1 \
    -k "F*£UYG*GIEJVKFDVKJDKvdfp'vdflvkhbkfjwgdjwac=" \
    -f "zZBaAx25FlzN,sdfgsk4frfr" \
    -d "/Users/username/Documents/Quip" \
    -c
```