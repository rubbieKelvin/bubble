import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	height: 45
	color: "#00000000"
	property alias icon: icon
	width: 45

	property int virt_width: 24
	property int virt_height: 24
	signal btnClicked()

	Rectangle{
		id: overlay
		anchors.fill: parent
		color: "#11000000"
		visible: false
	}

	Image {
		id: icon
		width: virt_width
		height: virt_height
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		fillMode: Image.PreserveAspectFit
		source: "qrc:/qtquickplugin/images/template_image.png"
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    hoverEnabled: true
	    onEntered: {
			overlay.visible = true
		}
	    onExited: {
			overlay.visible = false
		}
	    onClicked: {
			btnClicked();
		}
	}
}
