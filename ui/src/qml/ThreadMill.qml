import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	width: 276
	height: 72
	color: "#ffffff"

	property string text

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	BusyIndicator {
		y: 38
		anchors.left: parent.left
		anchors.leftMargin: 8
		anchors.verticalCenter: parent.verticalCenter
		running: true
	}

	Label {
		x: 80
		y: 8
		width: 188
		height: 56
		text: root.text
		font.family: montserrat.name
		verticalAlignment: Text.AlignVCenter
		anchors.verticalCenter: parent.verticalCenter
	}
}



/*##^## Designer {
    D{i:2;anchors_x:8}
}
 ##^##*/
