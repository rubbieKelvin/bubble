import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	height: 55
	radius: 5
	border.width: 1
	border.color: App.Colors.grey5
	width: 234
	color: "#00000000"

	property string file
	property string docname
	property string extension
	signal downloadClicked()

	Component.onCompleted:{
		docname = file.split("/").slice(-1)[0].split(".")[0];
		extension = file.split("/").slice(-1)[0].split(".").slice(-1)[0];
	}

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Rectangle {
		id: rectangle
		y: 8
		width: 45
		height: 45
		color: (App.Colors.document[extension]===undefined)?App.Colors.grey2:App.Colors.document[extension]
		radius: 5
		anchors.left: parent.left
		anchors.leftMargin: 4
		anchors.verticalCenterOffset: 0
		anchors.verticalCenter: parent.verticalCenter

		Label {
			color: "#ffffff"
			text: qsTr(extension)
			font.pixelSize: 10
			font.capitalization: Font.AllUppercase
			font.weight: Font.Medium
			font.family: montserrat.name
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			anchors.fill: parent
		}
	}

	Label {
		width: 129
		text: qsTr(docname)
		anchors.left: rectangle.right
		anchors.leftMargin: 4
		anchors.top: parent.top
		anchors.topMargin: 5
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 5
		font.pixelSize: 10
		verticalAlignment: Text.AlignVCenter
		font.family: montserrat.name
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true

		onEntered: {
			download_img.visible = true;
		}
		onExited: {
			download_img.visible = false
		}
	}

	Image {
		id: download_img
		x: 201
		y: 15
		width: 25
		height: 25
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: 8
		source: "../../res/images/download.png"
		fillMode: Image.PreserveAspectFit
		visible: false

		MouseArea {
			id: mouseArea1
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor

			onClicked:{
				downloadClicked()
			}

			onEntered: {
				download_img.visible = true
			}

			onExited: {
				download_img.visible = false
			}
		}
	}
}
