#!/usr/bin/env python

import os
import sys
import subprocess
import shutil

import yaml
import filecmp

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

def recursiveAction(src, dest, action):
    """
    Copy or symlink file from source to dest.  dest can include an absolute or relative path
    If the path doesn't exist, it gets created
    action:
      1 -> Copy
      2 -> Symlink
    """
    dest_dir = os.path.dirname(dest)
    try:
        os.makedirs(dest_dir)
    except os.error as e:
        pass #Assume it exists.  This could fail if you don't have permissions, etc...

    if action == 1:
        # Use copy2 to preserve almost all metadata like modification time etc
        # Do not follow symlinks as it can overwrite the original file too
        os.remove(dest)
        shutil.copy2(src, dest, follow_symlinks=False)
    else:
        os.symlink(os.path.join(genieCwd, _file['placed']), _location)

class Configuration:
    def __init__(self, _files=None, _directories=None, _subrepos=None):
        self.files = _files or []
        self.directories = _directories or []
        self.subrepos = _subrepos or []
    def __repr__(self):
        return "%s(files=%r,\n\ndirectories=%r,\n\nsubrepos=%r)" % (
            self.__class__.__name__, self.files, self.directories, self.subrepos)

def readConfig(fileName):
    fileDes = open(fileName, 'r')
    return yaml.load(fileDes)

print("Starting genie..")
configObject = readConfig(sys.argv[1])

# TODO get and set proper cwd
genieCwd = os.getcwd()

# Handle and place all files
for _file in configObject.files:
    _location = os.path.expandvars(_file['location'])
    # Check if this file already exists
    print("Placing file: " + _file['name'])

    # Action to be taken on file
    """
      0 -> Place symlink of the file there
      1 -> Don't copy, same file
      2 -> User aborted copy
      3 -> Place the file there, no symlinks
    """
    action = 0

    # Status of this file
    status = 0

    if os.path.isfile(_location):
        # Status 1 for file exists
        status = 1
        print("  Already exists")

        _readFrom = _location
        if os.path.islink(_location):
            # Status 2 if file is symlinked
            status = 2
            _readFrom = os.path.realpath(_location)
            print("  Already symlinked to " + _readFrom)

        # Can specify ignoreDiff key in config file to replace without diffing
        # Otherwise, default is to replace
        # TODO First check if the files are the same, to save diff times
        _modified = True
        if not "ignoreDiff" in _file:
            _modified = not filecmp.cmp(_readFrom, _file['placed'])
        if _modified:
            print("  Version has been modified. Diff:")
            subprocess.call(["diff", _readFrom, _file['placed']])

            # TODO check if this thing is already in the yaml
            print("Replace/Backup?")

            # TODO Check for user's opinion and set action accordingly

            # Assume backup
            # TODO allow multiple backups to persist
            recursiveAction(_readFrom, genieCwd + "/.backups/" + _file['placed'], 1)

        else:
            print("  Files are same, not copying")
            action = 1

    # Skip this file now
    if action == 1 or action == 2:
        continue

    # See if this file has to be plain copied or not
    if "plainCopy" in _file:
        action = 3

    # Symlink
    if action == 0:
        try:
            os.remove(_location)
        except:
            pass
        recursiveAction(os.path.join(genieCwd, _file['placed']), _location, 2)
        print("Symlinked " + _file['placed'] + " to " + _location)

    # Copy
    elif action == 3:
        recursiveAction(os.path.join(genieCwd, _file['placed']), _location, 1)
        print("Copied " + _file['placed'] + " to " + _location)
