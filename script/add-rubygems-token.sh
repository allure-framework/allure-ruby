#!/bin/bash

mkdir -p $HOME/.gem
printf -- "---\n:rubygems_api_key: ${GEM_HOST_API_KEY}\n" > $HOME/.gem/credentials
chmod 0600 $HOME/.gem/credentials
