#!/usr/bin/bash

CWD='/mnt/c/Users/colli/Documents/School/Tetramino-Versus'

flutter build web

cp -r $CWD/build/web/* $CWD/docs/

echo ""

echo "REMEMBER TO FIX INDEX.HTML, TITLE, AND DESCRIPTION"
