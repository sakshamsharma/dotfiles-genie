#!/usr/bin/env python

import os
import sys
import subprocess
import shutil
import distutils

import yaml
import filecmp

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

# TODO
# Move file and folder stuff to new files
# Abstract out the asking user for options part into a global helper function

def recursiveAction(src, dest, action, fileOrDir):
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


    # If there's a symlink there already, get it out
    if os.path.islink(dest):
        os.unlink(dest)

    # Copy all files, no symlinking
    if action == 1:
        # Use copy2 to preserve almost all metadata like modification time etc
        # Do not follow symlinks as it can overwrite the original file too

        # Copy according to file/directory behavior
        if fileOrDir == "dir":
            # shutil.copytree(src, dest, ignore_errors=True, copy_function=copy2)
            distutils.dir_util.copy_tree(src, dest)
        else:
            shutil.copy2(src, dest, follow_symlinks=False)

    # Default symlink behaviour
    else:
        os.symlink(src, dest)

"""
The config is read and parsed as this class
"""
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

# TODO Check for sys.argv and set a default
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
        # TODO Allow disabling backups globally in config file as well
        _modified = True
        if not "ignoreDiff" in _file:
            _modified = not filecmp.cmp(_readFrom, _file['placed'])
        if _modified:
            print("  Version has been modified. Diff:")
            subprocess.call(["diff", _readFrom, _file['placed']])
            print("")

            # 2 means not known
            _toBackup = 2
            if "action" in _file:
                if _file['action'] == "backup":
                    _toBackup = 1
                elif _file['action'] == "nobackup":
                    _toBackup = 0
                elif _file['action'] == "donothing":
                    action = 2

            # If nothing was written, ask user
            if (_toBackup == 1 or _toBackup == 2) and action != 2:
                if _toBackup == 2:
                    print("  Backup, Replace or skip? (b,r,s): ")
                    inp = input()
                    if inp == "r":
                        _toBackup = 0
                    elif inp == "s":
                        _toBackup = 0
                        action = 2
                    else:
                        _toBackup = 1

                if _toBackup == 1:
                    # TODO allow multiple backups to persist
                    print("  Backing up file")
                    recursiveAction(_readFrom, genieCwd + "/.backups/" + _file['placed'], 1, "file")

        else:
            print("  Files are same, not copying")
            action = 1

    # Skip this file now if user skipped, or files were same
    if action == 1 or action == 2:
        continue

    # See if this file has to be plain copied or not
    if "plainCopy" in _file:
        action = 3

    # Symlink if its plain old symlinked based action
    if action == 0:
        try:
            os.remove(_location)
        except:
            pass
        recursiveAction(os.path.join(genieCwd, _file['placed']), _location, 2, "file")
        print("Symlinked " + _file['placed'] + " to " + _location)

    # Copy if user had specified so in the config
    elif action == 3:
        recursiveAction(os.path.join(genieCwd, _file['placed']), _location, 1, "file")
        print("Copied " + _file['placed'] + " to " + _location)

print("")
print("")
# Handle and place all folders
for _file in configObject.directories:
    _location = os.path.expandvars(_file['location'])
    # Check if this folder already exists
    print("Placing folder: " + _file['name'])

    # Action to be taken on folder
    """
      0 -> Place symlink of the folder there
      1 -> Don't copy, same folder
      2 -> User aborted copy
      3 -> Place the folder there, no symlinks
    """
    action = 0

    # Status of this file
    status = 0

    if os.path.isdir(_location):
        # Status 1 for folder exists
        status = 1
        print("  Already exists")

        _readFrom = _location
        if os.path.islink(_location):
            # Status 2 if file is symlinked
            status = 2
            _readFrom = os.path.realpath(_location)
            print("  Already symlinked to " + _readFrom)

            # 2 means not known
            _toBackup = 2
            if "action" in _file:
                if _file['action'] == "backup":
                    _toBackup = 1
                elif _file['action'] == "nobackup":
                    _toBackup = 0
                elif _file['action'] == "donothing":
                    action = 2

            # If nothing was written, ask user
            if (_toBackup == 1 or _toBackup == 2) and action != 2:
                if _toBackup == 2:
                    print("  Backup, Replace or skip? (b,r,s): ")
                    inp = input()
                    if inp == "r":
                        _toBackup = 0
                    elif inp == "s":
                        _toBackup = 0
                        action = 2
                    else:
                        _toBackup = 1

                if _toBackup == 1:
                    # TODO allow multiple backups to persist
                    print("  Backing up file")
                    recursiveAction(_readFrom, genieCwd + "/.backups/" + _file['placed'], 1, "dir")

    # Skip this file now if user skipped, or files were same
    if action == 1 or action == 2:
        continue

    # See if this file has to be plain copied or not
    if "plainCopy" in _file:
        action = 3

    # Symlink if its plain old symlinked based action
    if action == 0:
        try:
            shutil.rmtree(_location, ignore_errors=True)
        except:
            pass
        recursiveAction(os.path.join(genieCwd, _file['placed']), _location, 2, "dir")
        print("Symlinked " + _file['placed'] + " to " + _location)

    # Copy if user had specified so in the config
    elif action == 3:
        recursiveAction(os.path.join(genieCwd, _file['placed']), _location, 1, "dir")
        print("Copied " + _file['placed'] + " to " + _location)
