import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	width: 700
	height: 600
	color: "#ffffff"

	property string path
	property string file
	signal rejected()
	signal downloadClicked()
	signal shareClicked()

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Component.onCompleted: {
		let is_image = files.is_image("")
	}

	Image{
		id: img
		fillMode: Image.PreserveAspectCrop
		anchors.fill: parent
		source: path
	}

	Rectangle{
		id: header
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.right: parent.right
		height: 50
		color: "#b3000000"

		Label{
			id: name
			width: 484
			height: 50
			color: "#ffffff"
			text: bubble.split(file).slice(15)
			clip: true
			font.weight: Font.Medium
			font.pixelSize: 14
			font.family: montserrat.name
			verticalAlignment: Text.AlignVCenter
			anchors.left: parent.left
			anchors.leftMargin: 10
		}

		RowLayout {
			x: 518
			y: 10
			width: 122
			height: 50
			spacing: 10
			anchors.right: parent.right
			anchors.rightMargin: 10
			anchors.verticalCenter: parent.verticalCenter

			WMBarButton{
				id: share_btn
				Layout.fillHeight: true
				Layout.fillWidth: true
				icon.source: "../../res/images/share-pop.png"
				tip: "share file"
				onClick:{
					shareClicked()
				}
			}

			WMBarButton{
				id: download_btn
				Layout.fillHeight: true
				Layout.fillWidth: true
				icon.source: "../../res/images/download-pop.png"
				tip: "download file"
				onClick:{
					downloadClicked()
				}
			}

			WMBarButton{
				id: cancel_btn
				Layout.fillHeight: true
				Layout.fillWidth: true
				icon.source: "../../res/images/cancel-pop.png"
				tip: "close pop-up"

				onClick:{
					rejected()
				}
			}
		}
	}

}
