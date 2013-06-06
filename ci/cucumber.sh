#!/bin/bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

rvm use 1.9.3@AgileToolbox_CI

set -ex

bundle install
cucumber
