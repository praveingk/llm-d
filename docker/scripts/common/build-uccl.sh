#!/bin/bash
set -Eeux

# builds and installs UCCL from source
#
# Required environment variables:
# - UCCL_REPO: git repo to build UCCL from
# - UCCL_VERSION: git ref to build UCCL from
# - UCCL_PREFIX: installation prefix for UCCL libraries and headers
#
# Optional environment variables:
# - UCCL_TRANSPORT: transport backend to use (default: rdma)
#   Options: rdma, efa, tcp, tcpx

UCCL_TRANSPORT="${UCCL_TRANSPORT:-rdma}"

cd /tmp

git clone "${UCCL_REPO}" uccl && cd uccl
git checkout -q "${UCCL_VERSION}"

mkdir -p "${UCCL_PREFIX}/lib" "${UCCL_PREFIX}/include"

cd p2p
make install-deps

case "${UCCL_TRANSPORT}" in
  efa)
    USE_EFA=1 make -j
    ;;
  tcp)
    USE_TCP=1 make -j
    ;;
  tcpx)
    USE_TCPX=1 make -j
    ;;
  *)
    make -j
    ;;
esac

PREFIX="${UCCL_PREFIX}" make install

cd /tmp
rm -rf uccl
