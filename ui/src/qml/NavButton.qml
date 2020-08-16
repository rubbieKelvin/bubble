import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	height: 50
	color: "#00000000"
	width: 170

	property alias image: image
	property bool selected: false
	property string title: "Nav Title"
	signal selectedClicked()
	signal selectedModeChanged(bool state)

	function set_state(state) {
		if (!selected && state){
			selectedModeChanged(true);
		}else if(selected && !state){
			selectedModeChanged(false);
		}
		selected = state;
	}

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Label {
		id: label
		y: 8
		height: 34
		color: (selected)?App.Colors.primary:App.Colors.grey3
		text: qsTr(title)
		font.weight: Font.Medium
		font.pixelSize: 12
		font.family: montserrat.name
		verticalAlignment: Text.AlignVCenter
		anchors.right: parent.right
		anchors.rightMargin: 8
		anchors.left: parent.left
		anchors.leftMargin: 40
		anchors.verticalCenter: parent.verticalCenter
	}

	Image {
		id: image
		y: 15
		width: 20
		height: 20
		anchors.left: parent.left
		anchors.leftMargin: 14
		anchors.verticalCenter: parent.verticalCenter
		fillMode: Image.PreserveAspectFit
		source: "qrc:/qtquickplugin/images/template_image.png"
	}


	Rectangle {
		width: 3
		color: App.Colors.primary
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 0
		anchors.top: parent.top
		anchors.topMargin: 0
		anchors.left: parent.left
		anchors.leftMargin: 0
		visible: selected
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    hoverEnabled: true
	    onEntered: {}
	    onExited: {}
	    onClicked: {
			if (!selected){
				selectedModeChanged(true);
			}
			selected = true;
			selectedClicked();
		}
	}
}
