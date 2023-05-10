#!/usr/bin/bash

CWD='/mnt/c/Users/colli/Documents/School/Tetramino-Versus'

flutter build web

echo "Done building web"

cp -r $CWD/build/web/* $CWD/docs/
