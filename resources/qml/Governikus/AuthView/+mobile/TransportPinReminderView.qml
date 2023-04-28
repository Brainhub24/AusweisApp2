/**
 * Copyright (c) 2020-2023 Governikus GmbH & Co. KG, Germany
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import Governikus.Global 1.0
import Governikus.Style 1.0
import Governikus.TitleBar 1.0
import Governikus.View 1.0

SectionPage {
	id: root

	property alias moreInformationText: moreInformationLink.text

	signal cancel
	signal pinKnown
	signal pinUnknown
	signal showInfoView

	navigationAction: NavigationAction {
		action: NavigationAction.Action.Cancel

		onClicked: cancel()
	}

	GFlickableColumnLayout {
		id: layout
		anchors.fill: parent
		spacing: Constants.component_spacing

		StatusIcon {
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredHeight: Style.dimens.header_icon_size
			Layout.preferredWidth: Style.dimens.header_icon_size
			source: "qrc:///images/status_info.svg"
		}
		GPane {
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			Layout.maximumWidth: Style.dimens.max_text_width

			//: LABEL ANDROID IOS
			title: qsTr("Do you know your six-digit ID card PIN?")

			GText {

				//: LABEL ANDROID IOS
				text: qsTr("Online identification with Transport PIN is not possible. The self-selected, six-digit ID card PIN is mandatory to use the eID function.")
				width: parent.width
			}
		}
		MoreInformationLink {
			id: moreInformationLink
			Layout.alignment: Qt.AlignCenter
			Layout.maximumWidth: layout.effectiveContentWidth
			Layout.topMargin: Constants.component_spacing

			onClicked: root.showInfoView()
		}
		GSpacer {
			Layout.fillHeight: true
		}
		RowLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			spacing: Constants.component_spacing

			GButton {
				Layout.alignment: Qt.AlignVCenter
				Layout.fillWidth: true
				Layout.maximumWidth: Style.dimens.max_text_width / 2

				//: LABEL ANDROID IOS
				text: qsTr("No")

				onClicked: pinUnknown()
			}
			GButton {
				Layout.alignment: Qt.AlignVCenter
				Layout.fillWidth: true
				Layout.maximumWidth: Style.dimens.max_text_width / 2

				//: LABEL ANDROID IOS
				text: qsTr("Yes")

				onClicked: pinKnown()
			}
		}
	}
}
