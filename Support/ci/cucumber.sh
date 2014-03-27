#!/bin/bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

rvm use 2.1.1@AgileToolbox_CI

set -ex

bundle install
cucumber
