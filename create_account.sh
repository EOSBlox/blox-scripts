#!/bin/sh
# Creates a new EOS account for a specified wallet.

if [ ! $# -eq 3 ]; then
  echo "Usage: $0 <account> <wallet> <wallet url>"
  exit 1
fi

ACCOUNT=$1
WALLET=$2
URL=$3

CLEOSCMD="cleos --wallet-url ${URL}"

function check_exit() {
  if [ ! $? -eq 0 ]; then
    exit $?
  fi
}

# Takes private key.
function import_key() {
  ${CLEOSCMD} wallet import $1 -n ${WALLET}
  check_exit
}

echo "Creating keys.."
RET=$(${CLEOSCMD} create key)
OWNER_PRIVKEY=$(echo ${RET} | awk '{print $3;}')
OWNER_PUBKEY=$(echo ${RET} | awk '{print $6;}')

RET=$(${CLEOSCMD} create key)
ACTIVE_PRIVKEY=$(echo ${RET} | awk '{print $3;}')
ACTIVE_PUBKEY=$(echo ${RET} | awk '{print $6;}')

echo "\n[OWNER]"
echo "Privkey: ${OWNER_PRIVKEY}"
echo "Pubkey:  ${OWNER_PUBKEY}"

echo "\n[ACTIVE]"
echo "Privkey: ${ACTIVE_PRIVKEY}"
echo "Pubkey:  ${ACTIVE_PUBKEY}"

echo "\nImporting private keys into ${WALLET} wallet.."
import_key ${OWNER_PRIVKEY}
import_key ${ACTIVE_PRIVKEY}

echo "\nCreating account ${ACCOUNT}.."
${CLEOSCMD} create account eosio ${ACCOUNT} ${OWNER_PUBKEY} ${ACTIVE_PUBKEY}
check_exit

echo "Success!"
