#!/bin/bash

# adapted from:
#  http://stoilis.wordpress.com/2010/06/18/automatically-remove-old-kernels-from-debian-based-distributions/
#  by Julien Moreau AKA PixEye.
# reworked by vbakayev to be able to:
# - not ask any questions - with "-y" option (version 1.1)
# - run as cronjob, producing no output (version 1.2)
# - cleaner flow, less external calls, small bugfix (1.3)
# - do not act upon 'efi.signed' kernels (1.4)
# - do not eval tput's if no tty (1.5)

echo_if_tty () { if [[ -t 1 ]]; then echo "$@"; fi }

if [[ -t 1 ]]; then
  # Text color variables
  rst=$(tput sgr0)	# Reset
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  purple=$(tput setaf 5)
  cyan=$(tput setaf 6)
  white=$(tput setaf 7)
  # options:
  bold=$(tput bold)
  underline=$(tput sgr 0 1)
fi

pushd /boot &>/dev/null || exit $?
INSTALLED_KERNELS=$(ls --color=never -1r vmlinuz-* | grep -v efi.signed$)
NUMBER_OF_INSTALLED_KERNELS=$(echo ${INSTALLED_KERNELS} | wc -w)
NUMBER_OF_KERNELS_TO_KEEP=2
LAST_INSTALLED_KERNEL=$(ls --color=never -1 vmlinuz-* | grep -v efi.signed$ | tail -n 1)
CURRENT_VERSION=$(uname -r)
RUNNING_KERNEL=$(ls --color=never -1 vmlinuz-$(uname -r) | grep -v efi.signed$)
popd &>/dev/null

if [ "${RUNNING_KERNEL}" != "${LAST_INSTALLED_KERNEL}" ]; then
  a1=${red}; a2=${green}
  echo_if_tty -e "${bold}${yellow}You need to reboot with the last installed kernel.${rst}"
fi
echo_if_tty -e "${bold}Current kernel is.......: ${a1}${RUNNING_KERNEL}${rst}"
echo_if_tty "/ Installed kernels:"
echo_if_tty ${INSTALLED_KERNELS}
echo_if_tty "\ -> ${NUMBER_OF_INSTALLED_KERNELS} kernels installed."
echo_if_tty -e "${bold}Last installed kernel is: ${a2}${LAST_INSTALLED_KERNEL}${rst}"

i=0; REMOVE_PATTERN=''
for k in ${INSTALLED_KERNELS}
do
  let $((i++))
  if [ ${i} -le ${NUMBER_OF_KERNELS_TO_KEEP} ]; then continue ; fi  # keep at least that many kernels
  if [ "${k}" == "${RUNNING_KERNEL}" ]; then continue; fi # do not remove running kernel

  k="$(echo ${k##vmlinuz-} | cut -d- -f-2)"
  # echo_if_tty "k_rm='$k'"  # for debug

  if [ "${REMOVE_PATTERN}" == '' ]; then
    REMOVE_PATTERN="${k}"
  else
    REMOVE_PATTERN="${REMOVE_PATTERN}|${k}"
  fi
done

if [ "${REMOVE_PATTERN}" == '' ]; then
  echo_if_tty -e "${bold}${green}There is no kernel to remove.${rst}" ; exit 0
fi

echo_if_tty -e "${bold}${yellow}Kernels to remove (pattern): ${REMOVE_PATTERN}.${rst}"

if [ "${LOGNAME}" != "root" ]; then
  echo_if_tty -e "${bold}${red}I need root privileges in order to clean!${rst}" ; exit 2
fi

REMOVE_PACKAGES=$(dpkg -l | awk "/linux-.*-${REMOVE_PATTERN}/ {print \$2}")
apt-get purge ${1} ${REMOVE_PACKAGES}
