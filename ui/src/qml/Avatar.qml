import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	width: 120
	height: 130
	color: is_selected ? "#804dc6e9":"#ffffff"
	
	property alias icon: icon
	property string title
	property string avatar_key
	property bool is_selected: false
	signal selected(var key)

	function deselect(){
		root.is_selected = false;
	}
	
	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Rectangle{
		id: overlay
		anchors.fill: parent
		color: "#804dc6e9"
		visible: false
	}
	
	Image{
		id: icon
		x: 5
		y: 0
		height: 100
		width: 100
		anchors.horizontalCenter: parent.horizontalCenter
		fillMode: Image.PreserveAspectFit
		source: "../../res/images/avatars/001-man.png"
	}
	
	
	Label {
		y: 109
		height: 17
		text: title
		anchors.right: parent.right
		anchors.rightMargin: 0
		anchors.left: parent.left
		anchors.leftMargin: 0
		font.pixelSize: 11
		font.family: montserrat.name
		horizontalAlignment: Text.AlignHCenter
	}
 
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true

		onClicked:{
			is_selected = !is_selected;
			if (is_selected){
				selected(avatar_key);
			}else{
				selected(null);
			}
		}

		onEntered:{
			overlay.visible = true;
		}

		onExited:{
			overlay.visible = false;
		}
	}
}


/*##^## Designer {
    D{i:3;anchors_width:144;anchors_x:8}
}
 ##^##*/
