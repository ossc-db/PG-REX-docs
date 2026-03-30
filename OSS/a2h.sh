#!/bin/bash

asciidoctor index.adoc

sed -i "s@href=\".*PG_rex.ico\"@href=\"data:image/png;base64,$(base64 -w0 ./images/PG_rex.ico)\"@" index.html

