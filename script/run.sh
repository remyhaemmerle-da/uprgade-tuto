#!/bin/bash

set -e

export V1=$(sed -n 's/^version: \(.*\)$/\1/p' ../v1/my-pkg/daml.yaml)
export V2=$(sed -n 's/^version: \(.*\)$/\1/p' ../v2/my-pkg/daml.yaml)
export V1_HELPER_SUFFIX=$(md5sum ../v1/*/daml.yaml ../v1/*/daml/*.daml | md5sum | cut -b1-32)
export V2_HELPER_SUFFIX=$(md5sum ../v2/*/daml.yaml ../v2/*/daml/*.daml | md5sum | cut -b1-32)

daml build --all

case $1 in

  upload-v1)
    daml ledger upload-dar --port 6865 ../v1/my-pkg/.daml/dist/my-pkg-${V1}.dar
    ;;

  upload-v2)
    daml ledger upload-dar --port 6865 ../v2/my-pkg/.daml/dist/my-pkg-${V2}.dar
    ;;

  upload-v1-helper)
    daml ledger upload-dar --port 6865 ../v1/helper/.daml/dist/helper-v${V1_HELPER_SUFFIX}-0.0.0.dar
    ;;

  upload-v2-helper)
    daml ledger upload-dar --port 6865 ../v2/helper/.daml/dist/helper-v${V2_HELPER_SUFFIX}-0.0.0.dar
    ;;

  build)
    daml build --all
    ;;

  pkgIds)
    echo -n " v1: "
    daml damlc inspect ../v1/my-pkg/.daml/dist/my-pkg-${V1}.dar | head -1
    echo -n " v2: "
    daml damlc inspect ../v2/my-pkg/.daml/dist/my-pkg-${V2}.dar | head -1
    ;;

  script)
    shift
    daml build
    daml script --ledger-host localhost --ledger-port 6865 --dar .daml/dist/script-0.0.0.dar --script-name $*
    ;;

  *)
    echo "usage: ./run.sh <cmd>"
    echo "   upload-v1"
    echo "   upload-v1-helper"
    echo "   upload-v2"
    echo "   upload-v1-helper"
    echo "   build-all"
    echo "   script"
    exit 1
    ;;

esac

