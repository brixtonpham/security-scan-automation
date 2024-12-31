#!/bin/bash

function load_env() {
    if [ -f ".env" ]; then
        while IFS='=' read -r key value; do
            if [ -n "$key" ] && [ "${key:0:1}" != '#' ]; then
                export "$key"="$value"
            fi
        done < .env
    else
        echo "[ERROR] .env file not found"
        exit 1
    fi
}

