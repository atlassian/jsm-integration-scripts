#!/bin/bash
if [  -z $(getent passwd jsm) ]
then
    groupadd jsm -r
    useradd -g jsm jsm -r -d /var/jsm/
fi