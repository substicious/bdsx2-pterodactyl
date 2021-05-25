#!/bin/bash

# Make sure we're in the correct dir
cd /BDSx2

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/BDSx2/$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}
