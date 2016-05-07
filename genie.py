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

def copytree(root_src_dir, root_dst_dir):
    for src_dir, dirs, files in os.walk(root_src_dir):
        dst_dir = src_dir.replace(root_src_dir, root_dst_dir, 1)
        if not os.path.exists(dst_dir):
            os.makedirs(dst_dir)
        for file_ in files:
            src_file = os.path.join(src_dir, file_)
            dst_file = os.path.join(dst_dir, file_)
            if os.path.exists(dst_file):
                os.remove(dst_file)
            shutil.copy(src_file, dst_dir)

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
        pass #Assume it exists.  This could fail if you don't have permissions


    # If there's a symlink there already, get it out
    if os.path.islink(dest):
        os.unlink(dest)

    # Copy all files, no symlinking
    if action == 1:
        # Copy according to file/directory behavior
        if fileOrDir == "dir":
            copytree(src, dest)
        else:
            shutil.copy2(src, dest, follow_symlinks=False)

    # Default symlink behaviour
    else:
        # Since makedirs would have made this directory as well
        if fileOrDir == "dir":
            # Issue with folder not being there
            # Use try to ignore the error of no such directory
            try:
                os.rmdir(dest)
            except:
                pass
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

# ==================
# Start of execution
# ==================
print("Starting genie..")

# Check for sys.argv and set a default
configFileLocation = 'conf.yml'
if len(sys.argv) == 1:
    print("Using default: conf.yml config")
else:
    configFileLocation = sys.argv[1]
    if len(sys.argv) != 2:
        print("Ignoring extra arguments")

configObject = readConfig(configFileLocation)

# Get the absolute location of the config file
genieCwd = os.path.join(os.getcwd(), configFileLocation.rpartition('/')[0])

# Clone all the repos first
for _repo in configObject.subrepos:
    _location = os.path.join(genieCwd, os.path.expandvars(_repo['location']))
    _origin = _repo['origin']
    print("Cloning " + _repo['name'])
    subprocess.call(["git", "clone", _origin, _location])

# Handle and place all folders
for _dir in configObject.directories:
    _location = os.path.expandvars(_dir['location'])
    _placed = _dir['placed']

    if _dir['placed'][0] != '/':
        # This is a relative path
        # Make it absolute
        _placed = os.path.join(genieCwd, _dir['placed'])

    print("Placing folder: " + _dir['name'])

    # Fix in case there is a trailing slash
    # If length is 1, it must be '/' which deserves to stay untouched
    if len(_location) > 1:
        _location = _location.rstrip('/')

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
        if "action" in _dir:
            if _dir['action'] == "backup":
                _toBackup = 1
            elif _dir['action'] == "nobackup":
                _toBackup = 0
            elif _dir['action'] == "donothing":
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
                print("  Backing up folder")
                recursiveAction(_readFrom, genieCwd + "/.backups/" + _dir['placed'], 1, "dir")

    # Skip this file now if user skipped, or files were same
    if action == 1 or action == 2:
        continue

    # See if this file has to be plain copied or not
    if "plainCopy" in _dir:
        action = 3

    # Symlink if its plain old symlinked based action
    if action == 0:
        if not os.path.islink(_location):
            shutil.rmtree(_location, ignore_errors=True)
        else:
            os.unlink(_location)
        recursiveAction(_placed, _location, 2, "dir")
        print("Symlinked " + _dir['placed'] + " to " + _location)

    # Copy if user had specified so in the config
    elif action == 3:
        recursiveAction(_placed, _location, 1, "dir")
        print("Copied " + _dir['placed'] + " to " + _location)

print("")
print("Placing files now")
print("")

# Handle and place all files
for _file in configObject.files:
    _location = os.path.expandvars(_file['location'])

    _placed = os.path.expandvars(_file['placed'])

    if _file['placed'][0] != '/':
        # This is a relative path
        # Make it absolute
        _placed = os.path.join(genieCwd, _placed)

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
            _modified = not filecmp.cmp(_readFrom, _placed)
        if _modified:
            print("  Version has been modified. Diff:")
            subprocess.call(["diff", _readFrom, _placed])
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
        recursiveAction(_placed, _location, 2, "file")
        print("Symlinked " + _file['placed'] + " to " + _location)

    # Copy if user had specified so in the config
    elif action == 3:
        recursiveAction(_placed, _location, 1, "file")
        print("Copied " + _file['placed'] + " to " + _location)
