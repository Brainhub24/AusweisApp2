# CPack
# http://www.cmake.org/Wiki/CMake:CPackConfiguration

SET(FILENAME ${PROJECT_NAME}-${PROJECT_VERSION})

IF(ANDROID)
	SET(FILENAME ${FILENAME}-${CMAKE_ANDROID_ARCH_ABI})
ENDIF()

IF(DEFINED dvcs_distance)
	SET(FILENAME ${FILENAME}+${dvcs_distance})
ENDIF()

IF(DEFINED dvcs_branch)
	SET(FILENAME ${FILENAME}-${dvcs_branch})
ENDIF()

IF(DEFINED dvcs_phase)
	SET(FILENAME ${FILENAME}-${dvcs_phase})
ENDIF()

IF(DEFINED dvcs_revision)
	SET(FILENAME ${FILENAME}-${dvcs_revision})
ENDIF()


SET(CPACK_PACKAGE_NAME ${PROJECT_NAME})
SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
SET(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
SET(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
SET(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
SET(CPACK_PACKAGE_VERSION_TWEAK ${PROJECT_VERSION_TWEAK})
SET(CPACK_PACKAGE_VENDOR "Governikus GmbH & Co. KG")
SET(CPACK_PACKAGE_CONTACT "info@governikus.com")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Governikus AusweisApp2")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/README.rst")
SET(CPACK_PACKAGE_FILE_NAME ${FILENAME})

IF(VENDOR_GOVERNIKUS)
	SET(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE.officially.txt")
ELSE()
	SET(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE.txt")
ENDIF()

IF(APPLE AND NOT IOS)
	FIND_PROGRAM(ICONV iconv)
	IF(NOT ICONV)
		MESSAGE(FATAL_ERROR "Cannot find 'iconv' to convert LICENSE.txt")
	ENDIF()

	EXECUTE_PROCESS(COMMAND ${ICONV} -f UTF-8 -t MAC ${CPACK_RESOURCE_FILE_LICENSE} OUTPUT_FILE "${PROJECT_BINARY_DIR}/LICENSE.txt")
	SET(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_BINARY_DIR}/LICENSE.txt")
ENDIF()

IF(${CMAKE_BUILD_TYPE} STREQUAL "RELEASE")
	SET(CPACK_STRIP_FILES TRUE)
ENDIF()

SET(CPACK_SOURCE_GENERATOR TGZ)
SET(CPACK_SOURCE_PACKAGE_FILE_NAME ${FILENAME} CACHE INTERNAL "tarball basename")

SET(CPACK_SOURCE_IGNORE_FILES "\\\\.hgignore" "\\\\.hgtags" "/\\\\.hg/")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "\\\\.gitignore" "/\\\\.git/")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "vendor.txt")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "${CMAKE_CURRENT_BINARY_DIR}")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "CMakeCache.txt")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "CMakeFiles")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "CMakeLists\\\\.txt\\\\.user")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "\\\\.project")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "\\\\.cproject")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "\\\\.reviewboardrc")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "utils/tlscheck")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "utils/testbedtool")
LIST(APPEND CPACK_SOURCE_IGNORE_FILES "utils/fuzzing")

SET(CPACK_MONOLITHIC_INSTALL true)


IF(WIN32)
	SET(CPACK_PACKAGE_EXECUTABLES "AusweisApp2;AusweisApp2")

	SET(CPACK_GENERATOR WIX)
	SET(CPACK_WIX_UPGRADE_GUID 4EE0E467-EAB7-483E-AB45-87BD1DB6B037)
	SET(CPACK_WIX_PRODUCT_ICON ${RESOURCES_DIR}/images/npa.ico)
	SET(CPACK_WIX_CULTURES de-DE en-US)
	# disable above line, enable beneath line to build MSI for english
	# SET(CPACK_WIX_CULTURES en-US)
	SET(CPACK_WIX_TEMPLATE ${PACKAGING_DIR}/win/WIX.template.in)
	SET(CPACK_WIX_UI_BANNER ${RESOURCES_DIR}/images/wix_banner.jpg)
	SET(CPACK_WIX_UI_DIALOG ${RESOURCES_DIR}/images/wix_dialog.jpg)
	SET(CPACK_WIX_EXTENSIONS WixUtilExtension)
	SET(CPACK_WIX_LIGHT_EXTRA_FLAGS -loc ${PACKAGING_DIR}/win/WIX.Texts.de-DE.wxl -loc ${PACKAGING_DIR}/win/WIX.Texts.en-US.wxl)

	IF(SIGNTOOL_CMD)
		MESSAGE(STATUS "MSI can be signed with 'make package.sign'")
		ADD_CUSTOM_TARGET(package.sign COMMAND ${SIGNTOOL_CMD} ${SIGNTOOL_PARAMS} ${PROJECT_BINARY_DIR}/${CPACK_PACKAGE_FILE_NAME}.msi)
	ENDIF()

ELSEIF(IOS)
	FILE(WRITE ${PROJECT_BINARY_DIR}/ipa.cmake "
		SET(BUNDLE_DIRS \"\${CONFIG}-iphoneos;\${CONFIG};UninstalledProducts;UninstalledProducts/iphoneos\")

		FOREACH(dir \${BUNDLE_DIRS})
			SET(tmpBundleDir ${PROJECT_BINARY_DIR}/src/\${dir}/${PROJECT_NAME}.app)
			IF(EXISTS \"\${tmpBundleDir}\")
				SET(BundleDir \"\${tmpBundleDir}\")
				BREAK()
			ENDIF()
		ENDFOREACH()

		IF(BundleDir)
			MESSAGE(STATUS \"Use bundle: \${BundleDir}\")
		ELSE()
			MESSAGE(FATAL_ERROR \"Bundle directory does not exist\")
		ENDIF()

		EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E copy_directory \${BundleDir} Payload/AusweisApp2.app)
		EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E tar cf \"${CPACK_PACKAGE_FILE_NAME}.ipa\" --format=zip Payload)
		EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E remove_directory Payload)
	")

	ADD_CUSTOM_TARGET(ipa COMMAND ${CMAKE_COMMAND} -DCONFIG=$<CONFIGURATION> -P ${CMAKE_BINARY_DIR}/ipa.cmake)

ELSEIF(APPLE)
	SET(MACOS_PACKAGING_DIR ${PACKAGING_DIR}/macos)
	SET(CPACK_GENERATOR Bundle)
	SET(CPACK_INSTALL_CMAKE_PROJECTS ${CMAKE_BINARY_DIR};${PROJECT_NAME};ALL;/)
	SET(CPACK_BUNDLE_NAME ${PROJECT_NAME})
	SET(CPACK_BUNDLE_ICON ${RESOURCES_DIR}/images/bundle_icons.icns)
	SET(CPACK_BUNDLE_APPLE_CERT_APP "Developer ID Application: Governikus GmbH & Co. KG (G7EQCJU4BR)")

	SET(CPACK_BUNDLE_APPLE_CODESIGN_FILES ${ADDITIONAL_BUNDLE_FILES_TO_SIGN})
	SET(CPACK_APPLE_BUNDLE_ID "com.governikus.AusweisApp2")
	SET(CPACK_BUNDLE_APPLE_CODESIGN_PARAMETER "--force")
	OPTION(OSX_TIMESTAMP "Timestamp the application bundle" ON)
	IF(OSX_TIMESTAMP)
		SET(CPACK_BUNDLE_APPLE_CODESIGN_PARAMETER "${CPACK_BUNDLE_APPLE_CODESIGN_PARAMETER} --timestamp")
	ELSE()
		SET(CPACK_BUNDLE_APPLE_CODESIGN_PARAMETER "${CPACK_BUNDLE_APPLE_CODESIGN_PARAMETER} --timestamp=none")
	ENDIF()
	SET(CPACK_PACKAGE_ICON ${RESOURCES_DIR}/images/dmg_icons.icns)
	SET(CPACK_DMG_VOLUME_NAME ${CPACK_PACKAGE_NAME})
	SET(CPACK_DMG_FORMAT UDBZ)
	SET(CPACK_DMG_BACKGROUND_IMAGE ${RESOURCES_DIR}/images/dmg_background.png)
	SET(CPACK_DMG_SLA_DIR ${MACOS_PACKAGING_DIR}/sla)
	SET(CPACK_DMG_SLA_LANGUAGES English German)

	# We can not generate the DS_STORE on each build since jenkins runs headless
	#SET(CPACK_DMG_DS_STORE_SETUP_SCRIPT ${MACOS_PACKAGING_DIR}/prepare-ds_store.applescript)
	SET(CPACK_DMG_DS_STORE ${MACOS_PACKAGING_DIR}/DS_STORE)

	SET(INFO_PLIST_FILE_NAME Info.plist)
	CONFIGURE_FILE(${MACOS_PACKAGING_DIR}/${INFO_PLIST_FILE_NAME} ${INFO_PLIST_FILE_NAME} @ONLY)
	SET(CPACK_BUNDLE_PLIST ${INFO_PLIST_FILE_NAME})

	SET(STARTUP_FILE_NAME start-ausweisapp2.sh)
	CONFIGURE_FILE(${MACOS_PACKAGING_DIR}/${STARTUP_FILE_NAME} ${STARTUP_FILE_NAME} @ONLY)
	SET(CPACK_BUNDLE_STARTUP_COMMAND ${STARTUP_FILE_NAME})

ELSEIF(ANDROID)
	FIND_PROGRAM(androiddeployqt androiddeployqt CMAKE_FIND_ROOT_PATH_BOTH)
	IF(NOT androiddeployqt)
		MESSAGE(FATAL_ERROR "Cannot find androiddeployqt to create APKs")
	ENDIF()
	MESSAGE(STATUS "Using androiddeployqt: ${androiddeployqt}")

	OPTION(ANDROID_USE_GRADLE "Use gradle for androiddeployqt" OFF)

	IF(${CMAKE_BUILD_TYPE} STREQUAL "RELEASE")
		IF(APK_SIGN_KEYSTORE AND APK_SIGN_KEYSTORE_ALIAS AND APK_SIGN_KEYSTORE_PSW)
			MESSAGE(STATUS "Release build will be signed using: ${APK_SIGN_KEYSTORE} | Alias: ${APK_SIGN_KEYSTORE_ALIAS}")
			SET(DEPLOY_CMD_SIGN --sign ${APK_SIGN_KEYSTORE} ${APK_SIGN_KEYSTORE_ALIAS} --storepass ${APK_SIGN_KEYSTORE_PSW} --digestalg SHA-256 --sigalg SHA256WithRSA)
			IF(ANDROID_USE_GRADLE)
				SET(APK_FILE dist-release-signed.apk)
			ELSE()
				SET(APK_FILE QtApp-release-signed.apk)
			ENDIF()
		ELSE()
			MESSAGE(FATAL_ERROR "Cannot sign release build! Set APK_SIGN_KEYSTORE, APK_SIGN_KEYSTORE_ALIAS and APK_SIGN_KEYSTORE_PSW!")
		ENDIF()

	ELSE()
		IF(ANDROID_USE_GRADLE)
			SET(APK_FILE dist-debug.apk)
		ELSE()
			SET(APK_FILE QtApp-debug.apk)
		ENDIF()
	ENDIF()

	SET(DEPLOY_CMD ${androiddeployqt} --verbose --input ${ANDROID_DEPLOYMENT_SETTINGS} --output ${CMAKE_INSTALL_PREFIX} ${DEPLOY_CMD_SIGN})

	IF(ANDROID_USE_GRADLE)
		SET(DEPLOY_CMD ${DEPLOY_CMD} --gradle)
		SET(SOURCE_APK_FILE ${CMAKE_INSTALL_PREFIX}/build/outputs/apk/${APK_FILE})
	ELSE()
		SET(SOURCE_APK_FILE ${CMAKE_INSTALL_PREFIX}/bin/${APK_FILE})
	ENDIF()

	SET(DESTINATION_APK_FILE ${CMAKE_INSTALL_PREFIX}/${CPACK_PACKAGE_FILE_NAME}.apk)
	# Add DEPENDS install someday
	# http://public.kitware.com/Bug/view.php?id=8438
	ADD_CUSTOM_TARGET(apk
				COMMAND ${DEPLOY_CMD}
				COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_APK_FILE} ${DESTINATION_APK_FILE})

	FIND_PROGRAM(apksigner apksigner HINTS ${ANDROID_SDK}/build-tools/${ANDROID_BUILD_TOOLS_REVISION} CMAKE_FIND_ROOT_PATH_BOTH)
	IF(apksigner)
		ADD_CUSTOM_TARGET(verify.signature COMMAND ${apksigner} verify --verbose --print-certs -Werr ${DESTINATION_APK_FILE})
	ENDIF()

ELSEIF(UNIX)
	SET(CPACK_GENERATOR STGZ)
ENDIF()


INCLUDE(CPack)
