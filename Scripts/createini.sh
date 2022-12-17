#!/bin/bash

INI=$1
DIR=$(basename -s .ini ${INI})
ROM="${DIR}/${DIR}.rom"
ADF="${DIR}/${DIR}.adf"
TEMPLATE="amiga_m68k"

ROOT=$(realpath $(dirname ${BASH_SOURCE[0]})/..)

TEMPLATE_INI="${ROOT}/${TEMPLATE}/replay.ini"

sed "s|^#ROM.*=.*test.rom.*|ROM\ =\ \"${ROM}\",0,0x00000000|" ${TEMPLATE_INI} > ${INI}
