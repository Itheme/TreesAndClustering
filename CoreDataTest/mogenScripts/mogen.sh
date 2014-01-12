#!/bin/sh
#  mogen.sh
#
#  Created by Jean-Denis Muys on 24/02/11.
#  Modified by Ryan Rounkles on 15/5/11 to use correct model version and to account for spaces in file paths

#TODO: Change this to the name of custom ManagedObject base class
#  If no custom MO class is required, remove the "--base-class $baseClass" parameter from mogenerator call
baseClass=DOManagedObject

echo mogenerator --model \"${INPUT_FILE_PATH}\" --output-dir \"${INPUT_FILE_DIR}/\" --base-class $baseClass
mogenerator --model "${INPUT_FILE_PATH}" --output-dir "${INPUT_FILE_DIR}/" --base-class $baseClass

echo ${DEVELOPER_BIN_DIR}/momc -XD_MOMC_TARGET_VERSION=10.6 \"${INPUT_FILE_PATH}\" \"${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}/${INPUT_FILE_BASE}.mom\"
${DEVELOPER_BIN_DIR}/momc -XD_MOMC_TARGET_VERSION=10.6 "${INPUT_FILE_PATH}" "${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}/${INPUT_FILE_BASE}.mom"

echo "that's all folks. mogen.sh is done"