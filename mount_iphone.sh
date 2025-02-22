#!/bin/bash

MOUNT_PATH="/mnt/iPhone/"

rmdir $MOUNT_PATH

fusermount -u $MOUNT_PATH

idevicepair pair

mkdir $MOUNT_PATH

ifuse $MOUNT_PATH
