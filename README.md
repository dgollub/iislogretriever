# IIS log file retriever tool

A simple Windows command line tool to get the IIS log files for a specified date range in a handy ZIP file.


# Development

This tool is build using the [D Programming Language](https://dlang.org/) using the [dub](https://code.dlang.org/getting_started) build tool.

If you want to compile this on your own, simply download and install a recent D package (on Windows you can use [Chocolately](https://chocolatey.org/) to do so), and run the following command

```bash
dub build
```

to compile the tool. The compiled binary will be in the `build` directory.


# Usage

Example: run `iislogsretriever.exe --start "2016-11-01" --end "2017-01-31"` to get all the IIS logs for all websites between Nov 1st 2016 and Jan 31st 2017.

The log file folder is assumed to be in `%SystemDrive%\inetpub\logs\LogFiles` if not specified as argument (`--logfolder`). Additional parameters are as follows:

```bash
--start     The start date (YYYY-MM-DD).
--end       The end date (YYYY-MM-DD).
--logfolder The log files root folder.
--out       The output folder.
```

Out of these only `--start` must be set. Everything else is optional.

## Known Issues / Limits

* If the default IIS log files folder was changed, you will need to specify with the command line argument `--logfolder`.
* If you set up individual log folders for sites, you will need to run the tool separately on those. There is no autodetection for this (yet).


# Contributions

Feel free to submit a PR if you'd like to contribute. I'll likely accept it.


# Copyright

Copyright (c) 2017 by Daniel Kurashige-Gollub <daniel@kurashige-gollub.de>


# License

Licensed under MIT license. See LICENSE file.
