#!/bin/bash
# Created with package:mono_repo v1.2.1

if [ -z "$PKG" ]; then
  echo -e '\033[31mPKG environment variable must be set!\033[0m'
  exit 1
fi

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

pushd $PKG
pub upgrade || exit $?

EXIT_CODE=0

while (( "$#" )); do
  TASK=$1
  case $TASK in
  command_0) echo
    echo -e '\033[1mTASK: command_0\033[22m'
    echo -e 'dartanalyzer --fatal-warnings .'
    dartanalyzer --fatal-warnings . || EXIT_CODE=$?
    ;;
  command_1) echo
    echo -e '\033[1mTASK: command_1\033[22m'
    echo -e 'dartfmt --dry-run --set-exit-if-changed .'
    dartfmt --dry-run --set-exit-if-changed . || EXIT_CODE=$?
    ;;
  command_2) echo
    echo -e '\033[1mTASK: command_2\033[22m'
    echo -e 'pub run test --platform vm'
    pub run test --platform vm || EXIT_CODE=$?
    ;;
  command_3) echo
    echo -e '\033[1mTASK: command_3\033[22m'
    echo -e 'pub run test --platform chrome'
    pub run test --platform chrome || EXIT_CODE=$?
    ;;
  *) echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    EXIT_CODE=1
    ;;
  esac

  shift
done

exit $EXIT_CODE
