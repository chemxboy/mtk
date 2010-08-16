#!/usr/bin/env bash
# Convert Mobile account to Local
# @author Filipp Lepalaan <filipp@mcare.fi>
# @copyright No (c), Public Domain software

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
homedir=$(dscl . read "/Users/$username" NFSHomeDirectory | sed 's/.*: //g')

if [[ ! -d $homedir ]]; then
  echo "Invalid user $username" >&2
  exit 1
fi

realname=$(dscl . read "/Users/$username" RealName | sed 's/.*: //g')

nextid() {
  max_id=$(dscl . -list $1 $2 | awk '{print $2}' | sort -n | tail -n 1)
  (( max_id++ ))
  echo $max_id
}

new_uid=$(nextid /Users UniqueID)
new_gid=$(nextid /Groups PrimaryGroupID)

newhome="/Users/$username"

# Delete mobile account
dscl . -delete /Users/$username

# Create local user
dscl . -create /Users/$username UniqueID $new_uid
dscl . -create /Users/$username RealName "$realname"
dscl . -create /Users/$username UserShell "/bin/bash"
dscl . -create /Users/$username GeneratedUID $(uuidgen)
dscl . -create /Users/$username PrimaryGroupID 20
dscl . -create /Users/$username NFSHomeDirectory $newhome

# Give admin perms
dscl . -append /Groups/admin users $username

# Set the password
dscl . -passwd /Users/$username "$password"

# Set correct permissions
chown -R $username:staff $newhome

exit 0
