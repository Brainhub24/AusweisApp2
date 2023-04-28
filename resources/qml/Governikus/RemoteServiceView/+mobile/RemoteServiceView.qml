/**
 * Copyright (c) 2017-2023 Governikus GmbH & Co. KG, Germany
 */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Governikus.Global 1.0
import Governikus.TitleBar 1.0
import Governikus.Style 1.0
import Governikus.View 1.0
import Governikus.Type.ApplicationModel 1.0
import Governikus.Type.RemoteServiceModel 1.0

SectionPage {
	id: baseItem
	hiddenNavbarPadding: true
	sectionPageFlickable: contentItem

	//: LABEL ANDROID IOS
	title: qsTr("Remote service")

	navigationAction: NavigationAction {
		action: RemoteServiceModel.running ? NavigationAction.Action.Cancel : NavigationAction.Action.None

		onClicked: RemoteServiceModel.setRunning(false)
	}

	Connections {
		function onFireIsRunningChanged() {
			setLockedAndHidden(RemoteServiceModel.running);
			pairingButton.didPairInSaKSession = false;
		}
		function onFirePairingCompleted() {
			pairingButton.didPairInSaKSession = true;
		}
		//: ERROR ANDROID IOS An error occurred while pairing the device.
		function onFirePairingFailed() {
			ApplicationModel.showFeedback(qsTr("Pairing failed. Please start a new pairing process on your other device and enter the shown pairing code."));
		}

		target: RemoteServiceModel
	}
	RemoteServiceController {
		id: controller
	}
	GFlickableColumnLayout {
		id: contentItem
		anchors.fill: parent
		maximumContentWidth: Style.dimens.max_text_width
		spacing: 0

		states: [
			State {
				name: "PAIRING"
				when: RemoteServiceModel.running && RemoteServiceModel.isPairing

				PropertyChanges {
					target: pairingCode
					visible: true
				}
				PropertyChanges {
					target: wifiInfo
					visible: true
				}
				PropertyChanges {
					target: networkPermissionText
					visible: RemoteServiceModel.requiresLocalNetworkPermission
				}
			},
			State {
				name: "UNCONNECTED"
				when: RemoteServiceModel.running && !RemoteServiceModel.connectedToPairedDevice

				PropertyChanges {
					target: pairingCode
					visible: false
				}
				PropertyChanges {
					target: wifiInfo
					visible: true
				}
				PropertyChanges {
					target: networkPermissionText
					visible: RemoteServiceModel.requiresLocalNetworkPermission
				}
			},
			State {
				name: "CONNECTED_OR_STOPPED"
				when: !RemoteServiceModel.running || (RemoteServiceModel.running && RemoteServiceModel.connectedToPairedDevice)

				PropertyChanges {
					target: pairingCode
					visible: false
				}
				PropertyChanges {
					target: wifiInfo
					visible: false
				}
				PropertyChanges {
					target: networkPermissionText
					visible: false
				}
			}
		]

		Image {
			Layout.alignment: Qt.AlignHCenter
			Layout.maximumWidth: contentItem.effectiveContentWidth
			Layout.preferredHeight: Style.dimens.medium_icon_size
			fillMode: Image.PreserveAspectFit
			source: "qrc:///images/phone_to_pc.svg"
			sourceSize.height: Style.dimens.medium_icon_size
		}
		GText {
			Layout.fillWidth: true
			Layout.topMargin: Constants.component_spacing
			horizontalAlignment: Text.AlignHCenter

			//: LABEL ANDROID IOS
			text: !ApplicationModel.wifiEnabled ? qsTr("WiFi not active") :
			//: LABEL ANDROID IOS
			RemoteServiceModel.canEnableNfc ? qsTr("NFC not active") :
			//: LABEL ANDROID IOS
			!RemoteServiceModel.runnable ? qsTr("Remote service not available") :
			//: LABEL ANDROID IOS
			RemoteServiceModel.connectedToPairedDevice ? qsTr("Card access in progress") :
			//: LABEL ANDROID IOS
			RemoteServiceModel.isPairing || RemoteServiceModel.running ? qsTr("Waiting for connection") :
			//: LABEL ANDROID IOS
			qsTr("Remote service ready")
			textStyle: Style.text.header_accent
		}
		GText {
			readonly property string currentPin: RemoteServiceModel.psk
			//: INFO ANDROID IOS
			readonly property string enterCodeString: qsTr("Enter the code %1 in the %2 on your other device to use your smartphone as a card reader (SaC).")

			Accessible.name: RemoteServiceModel.isPairing ? enterCodeString.arg(currentPin.split("").join(" ")).arg(Qt.application.name) : text
			Layout.fillWidth: true
			Layout.topMargin: Constants.text_spacing
			horizontalAlignment: Text.AlignHCenter
			text: !RemoteServiceModel.runnable ? RemoteServiceModel.errorMessage : RemoteServiceModel.running && RemoteServiceModel.connectedToPairedDevice ? RemoteServiceModel.connectionInfo : RemoteServiceModel.isPairing ? enterCodeString.arg(currentPin).arg(Qt.application.name) :
			//: INFO ANDROID IOS
			RemoteServiceModel.running ? qsTr("Waiting for connection from a paired device...") :
			//: INFO ANDROID IOS
			qsTr("Start the remote access in order to make this smartphone visible and use it as a card reader (SaC).\n\nIf you have not already paired a device, start the pairing now to set up this smartphone as a card reader.")
			textStyle: RemoteServiceModel.runnable ? Style.text.normal_secondary : Style.text.normal_warning
		}
		GText {
			id: pairingCode

			readonly property string currentPin: RemoteServiceModel.psk.toString()

			Accessible.ignored: true
			Layout.fillWidth: true
			Layout.topMargin: Constants.component_spacing
			horizontalAlignment: Text.AlignHCenter

			//: LABEL ANDROID IOS
			text: qsTr("Pairing code: <b>%1</b>").arg(RemoteServiceModel.isPairing ? currentPin : "0000")
			textStyle: Style.text.title_accent
			visible: false
		}
		GSpacer {
			Layout.fillHeight: true
		}
		RowLayout {
			id: wifiInfo
			Layout.fillWidth: true
			Layout.topMargin: Constants.component_spacing
			spacing: Constants.text_spacing

			TintableIcon {
				source: "qrc:/images/info.svg"
				sourceSize.width: Style.dimens.small_icon_size
				tintColor: Style.text.normal_secondary.textColor
			}
			GText {
				Layout.fillWidth: true

				//: INFO ANDROID IOS The remote service is active. Hint that both devices need to be connected to the same network.
				text: qsTr("Both of your devices have to be connected to the same WiFi.")
				textStyle: Style.text.normal_secondary
			}
		}
		LocalNetworkInfo {
			id: networkPermissionText
			Layout.bottomMargin: Constants.text_spacing
			Layout.fillWidth: true
			Layout.topMargin: Constants.component_spacing
			visible: false
		}
		GButton {
			id: startButton

			readonly property int minButtonWidth: Math.max(Math.max(pairingButton.implicitWidth, startButton.implicitWidth), parent.width / 2)

			Layout.alignment: Qt.AlignHCenter
			Layout.minimumWidth: startButton.minButtonWidth
			Layout.topMargin: Constants.component_spacing
			buttonColor: (!ApplicationModel.wifiEnabled || RemoteServiceModel.canEnableNfc) ? Style.color.button : (RemoteServiceModel.running ? Constants.red : Constants.green)
			enabled: (RemoteServiceModel.canEnableNfc || RemoteServiceModel.runnable || RemoteServiceModel.running || !ApplicationModel.wifiEnabled) && !RemoteServiceModel.isStarting
			//: LABEL ANDROID IOS
			text: !ApplicationModel.wifiEnabled ? qsTr("Enable WiFi") :
			//: LABEL ANDROID IOS
			RemoteServiceModel.canEnableNfc ? qsTr("Enable NFC") :
			//: LABEL ANDROID IOS
			RemoteServiceModel.running ? qsTr("Stop remote service") :
			//: LABEL ANDROID IOS
			qsTr("Start remote service")

			onClicked: {
				if (!ApplicationModel.wifiEnabled) {
					ApplicationModel.enableWifi();
				} else if (RemoteServiceModel.canEnableNfc) {
					ApplicationModel.showSettings(ApplicationModel.SETTING_NFC);
				} else {
					RemoteServiceModel.setRunning(!RemoteServiceModel.running);
				}
			}
		}
		GButton {
			id: pairingButton

			property bool didPairInSaKSession: false

			Layout.alignment: Qt.AlignHCenter
			Layout.minimumWidth: startButton.minButtonWidth
			Layout.topMargin: Constants.component_spacing
			enabled: RemoteServiceModel.runnable && !RemoteServiceModel.connectedToPairedDevice && !RemoteServiceModel.isStarting && !didPairInSaKSession

			// Set opacity instead of visibility to hide button so it keeps its size
			opacity: RemoteServiceModel.connectedToPairedDevice || didPairInSaKSession ? 0 : 1
			text: RemoteServiceModel.isPairing ?
			//: LABEL ANDROID IOS
			qsTr("Stop pairing") :
			//: LABEL ANDROID IOS
			qsTr("Start pairing")
			visible: RemoteServiceModel.runnable

			onClicked: RemoteServiceModel.setRunning(true, !RemoteServiceModel.isPairing)
		}
	}
}
