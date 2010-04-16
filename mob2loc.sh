#!/usr/bin/env bash
# Convert Mobile account to Local

if [[ $USER != "root" ]]; then
  echo "This tool must be run as root" >&2
  exit 1
fi

usage="usage: $(basename $0) username password"

if [[ $# -lt 2 ]]; then
  echo $usage 2>&1
  exit 1
fi

username=$1
password=$2

# First check that user exists
homedir=$(dscl . read "/users/$username" NFSHomeDirectory | sed 's/.*: //')

if [[ ! -d $homedir ]]; then
  echo "Invalid user $username" >&2
  exit 1
fi

nextid() {
  max_id=$(dscl . -list $1 $2 | awk '{print $2}' | sort -n | tail -n 1)
  (( max_id++ ))
  echo $max_id
}

new_uid=$(nextid /users UniqueID)
new_gid=$(nextid /groups PrimaryGroupID)

newhome="/Users/$username"

# Delete mobile account
dscl . -delete /users/$username

# Create local user
dscl . -create /users/$username UniqueID $new_uid
dscl . -create /users/$username RealName "$new_rn"
dscl . -create /users/$username UserShell "/bin/bash"
dscl . -create /users/$username GeneratedUID $(uuidgen)
dscl . -create /users/$username PrimaryGroupID 20
dscl . -create /users/$username NFSHomeDirectory $newhome

# Give admin perms
dscl . -append /groups/admin users $username

# Set the password
dscl . -passwd /users/$username "$password"

# Set correct permissions
chown -R $username:staff $newhome
