#!/usr/bin/env bash
for h in $(cat hosts.txt); do
    ip=$(dig +search +short $h)
    ssh-keygen -R $h
    ssh-keygen -R $ip
    ssh-keyscan -H $ip >> ~/.ssh/known_hosts
    ssh-keyscan -H $h >> ~/.ssh/known_hosts
done