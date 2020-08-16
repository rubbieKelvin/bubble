import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	height: 70
	color: "#00000000"
	width: 234

	property string contactname: "Contact"
	property string contactdescr: "Here's the last message i sent"
	property string time: "10:29"
	property string c_id: ""
	property string avatar: ""

	signal openContact()

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Component.onCompleted:{
		let avatar_ = user.get_avatar_by_id(avatar);
		avatar_ = JSON.parse(avatar_);
		contact_image.source = "../../res/images/avatars/"+avatar_.source;
	}

	Rectangle{
		id: overlay_rect
		color: "#11000000"
		anchors.fill: parent
		visible: false
	}

	Image {
		id: contact_image
		y: 8
		width: 35
		height: width
		anchors.left: parent.left
		anchors.leftMargin: 8
		anchors.verticalCenter: parent.verticalCenter
		fillMode: Image.PreserveAspectFit
	}


	ColumnLayout {
		y: 12
		height: 36
		anchors.right: parent.right
		anchors.rightMargin: 48
		anchors.left: contact_image.right
		anchors.leftMargin: 5
		anchors.verticalCenter: parent.verticalCenter

		Label {
			id: contact_name
			color: App.Colors.grey2
			text: qsTr(contactname)
			font.capitalization: Font.Capitalize
			Layout.fillWidth: true
			Layout.preferredHeight: 17
			Layout.preferredWidth: 128
			font.weight: Font.Medium
			font.pixelSize: 13
			font.family: montserrat.name
		}

		Label {
			id: contact_descr
			text: qsTr(contactdescr.slice(0, (contactdescr.length>22)?22:contactdescr.length)+"...")
			wrapMode: Text.NoWrap
			clip: true
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.preferredHeight: 17
			Layout.preferredWidth: 128
			font.pixelSize: 11
			font.family: montserrat.name
			color: App.Colors.grey4
		}
	}
	
	Label {
		x: 200
		y: 8
		text: qsTr(time)
		anchors.verticalCenterOffset: -10
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: 8
		font.pixelSize: 11
		font.family: montserrat.name
		color: App.Colors.grey4
		font.weight: Font.Medium
	}

	MouseArea {
		hoverEnabled: true
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onEntered:{
			overlay_rect.visible = true;
		}

		onExited: {
			overlay_rect.visible = false;
		}

		onClicked:{
			openContact();
		}
	}

}

