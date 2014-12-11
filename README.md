UpdateVersionRes
=============

Utility that updates VersionInfo structure in already compiled *.res file.

Created using [ResourceUtils](http://www.wilsonc.demon.co.uk/d10resourceeditor.htm) by [Colin Wilson](colin@wilsonc.demon.co.uk).

This utility can be used as pre-build step in C++ builder or Delphi to update VersionInfo structure, witch is stored in <ProjectName>.res file.

Build number can be updated by IDE automatically, however you may want to set version number in more complicated way.
For example using current year and month as version part. 

usage:  UpdateVersionRes filename.res [/pv or /fv] 1.2.3.4
where:
  /pv - set only ProductVersion
  /fv - set only FileVersion
  both ProductVersion and FileVersion are set by default

  1.2.3.4 is new version string witch can contain following elements:
  123   number
  *     leave old value
  +1    increment version number
  YYYY  current year
  MM    current month
  DD    current day

example: UpdateVersionRes resfile.res YYYY.MM.DD.*