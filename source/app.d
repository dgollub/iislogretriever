//
// Get the log files for a specified date range from the
// IIS log folder, zip them up and put them in an output
// folder.
//
// Copyright (c) 2017 by Daniel Kurashige-Gollub <daniel@kurashige-gollub.de>
//
import std.stdio;
import std.getopt;
import std.datetime : Date, DateTimeException, SysTime, DateTime;
import std.file : DirEntry, exists, write, remove, read, getcwd;
import std.path : buildNormalizedPath, dirSeparator;
import std.process : environment;
import core.stdc.stdlib : exit;
import std.string : representation, replace;
import std.zip;

version(Windows)
{

    void main(string[] args)
    {
    //version (Posix)
    //{
    //     string logFolder = environment.get("HOME", ".") ~ `/.inetpub/logs/LogFiles`;
    //}
    //else
    //{
        string logFolder = environment.get("%SystemDrive%", "C:") ~ `\inetpub\logs\LogFiles`;
    //}
        string startDate = null;
        string endDate = null;
        string outputFolder = getcwd();

        auto helpInfo = getopt(args,
                               "start", "The start date (YYYY-MM-DD).", &startDate,
                               "end", "The end date (YYYY-MM-DD).", &endDate,
                               "logfolder", "The log files root folder (current: " ~ logFolder ~ ").", &logFolder,
                               "out", "The output folder (current: " ~ outputFolder ~ ").", &outputFolder);

        if (helpInfo.helpWanted || startDate == null)
        {
            defaultGetoptPrinter("Zip IIS log files for a date/date range.",
                                 helpInfo.options);
            exit(1);
        }

        if (endDate == null) endDate = startDate;

        if (!exists(logFolder))
        {
            writefln("The IIS log folder does not exists: %s", logFolder);
            writeln("Please make sure that you point to the right folder.");
            exit(1);
        }

        if (!exists(outputFolder)) {
            writefln("ERROR: the output folder does not exists: %s", outputFolder);
            exit(1);
        }

        writefln("Start date: %s", startDate);
        writefln("End date  : %s", endDate);
        writefln("Out folder: %s", outputFolder);
        writefln("Log folder: %s", logFolder);

        DateTime start;
        try {
            start = DateTime.fromISOExtString(startDate ~ "T00:00:00");
        } catch(DateTimeException ex) {
            writefln("ERROR: could not convert date: %s", ex.msg);
            exit(1);
        }

        DateTime end;
        try {
            end = DateTime.fromISOExtString(endDate ~ "T23:59:59");
        } catch(DateTimeException ex) {
            writefln("ERROR: could not convert date: %s", ex.msg);
            exit(1);
        }

        string[] files = listFilesInDateRange(logFolder, start, end);

        if (files.length == 0) {
            writefln("No log files found for given date range: %s - %s", start, end);
            exit(2);
        }


        ZipArchive zip = new ZipArchive();

        foreach (string name; files)
        {
            writefln("... Adding to zip: %s", name);
            const string archiveEntryName = name.replace(logFolder ~ dirSeparator, "").replace(logFolder, "");
            //writeln(archiveEntryName);
            DirEntry f = DirEntry(name);
            void[] data = f.read();

            // Create an ArchiveMember for the test file.
            ArchiveMember am = new ArchiveMember();
            am.name = archiveEntryName;
            am.expandedData(cast(ubyte[])data);
            // Create an archive and add the member.
            zip.addMember(am);
        }

        string outputFile = buildNormalizedPath(outputFolder, "logFiles.zip");

        writefln("Writing output file: %s", outputFile);
        // Build the archive
        void[] compressed_data = zip.build();
        // Write to a file

        if (exists(outputFile)) {
            remove(outputFile);
        }
        write(outputFile, compressed_data);

        writefln("Done. ZIP file written to %s", outputFile);
    }

}
else // !version(Windows)
{
    void main()
    {
        static assert(false, "This application is for Windows only!");
    }
}

/**/
string[] listFilesInDateRange(const string root, const DateTime start, const DateTime end)
{
    import std.file : DirEntry, dirEntries, SpanMode, isFile, FileException;
    import std.path : extension;
    import std.algorithm : filter, map;
    import std.array : array;

    const SysTime sysStart = SysTime(start);
    const SysTime sysEnd = SysTime(end);

    //writefln("Start: %s", sysStart.toISOExtString());
    //writefln("End  : %s", sysEnd.toISOExtString());

    bool dateFits(DirEntry file)
    {
        const SysTime t = file.timeLastModified;

        if (t >= sysStart && t <= sysEnd) {
            //writefln("%s: %s", t.toISOExtString(), file.name);
            return true;
        }

        //writefln("WARN! File date/time [%s] from file: %s", t.toISOExtString(), file.name);

        return false;
    }

    return dirEntries(root, SpanMode.depth)
        .filter!(a => a.isFile && a.extension == ".log" && dateFits(a))
        .map!(a => a.name)
        .array;
}
