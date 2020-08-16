import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	width: 250
	height: 200
	color: "#ffffff"

	property string path
	property string file
	signal clicked()

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Image{
		id: img
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		source: path
	}

	Rectangle{
		id: overlay
		anchors.fill: parent
		color: "#22000000"
	}

	MouseArea {
	    anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		onEntered: overlay.visible=false;
		onExited: overlay.visible=true;
		onClicked: {
			root.clicked()
		}
	}
}
