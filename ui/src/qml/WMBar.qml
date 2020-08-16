import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	height: 30
	width: 700
	color: App.Colors.dark
	property alias icon: icon
	property alias buttonrow: buttonrow

	property var parentWindow: null
	property int prevX
    property int prevY
    property bool moving: false
	property bool parentMaximized: true

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Image {
		id: icon
		y: 8
		width: 15
		height: 15
		anchors.left: parent.left
		anchors.leftMargin: 8
		anchors.verticalCenter: parent.verticalCenter
		source: "../../res/images/bubble-xsm.png"
		fillMode: Image.PreserveAspectFit
	}

	Label {
		id: title
		y: 0
		width: 530
		height: 30
		color: "#ffffff"
		text: (parentWindow===null)?qsTr("QPenumbra"):parentWindow.title
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: icon.right
		anchors.leftMargin: 7
		font.weight: Font.Light
		font.capitalization: Font.Capitalize
		font.pointSize: 10
		font.family: montserrat.name
		verticalAlignment: Text.AlignVCenter
	}

	RowLayout {
		id: buttonrow
		x: 580
		y: 0
		spacing: 2
		anchors.right: parent.right
		anchors.rightMargin: 0

		WMBarButton {
			id: qPenumbraWMBarButton2
			icon.source: "../../res/images/minimize.png"
			onClick: {
				if (parentWindow !== null){
					parentWindow.showMinimized()
				}
			}
		}

		WMBarButton {
			id: qPenumbraWMBarButton1
			icon.source: "../../res/images/restoredown.png"
			onClick:{
				if(parentWindow !== null){
					if(parentMaximized){
						parentWindow.showNormal()
					}else{
						parentWindow.showMaximized()
					}
					parentMaximized = !parentMaximized;
				}
			}
		}

		WMBarButton {
			id: qPenumbraWMBarButton
			icon.source: "../../res/images/cancel.png"
			onClick:{
				if (parentWindow !== null){
					App.close(parentWindow);
				}
			}
		}
	}

	MouseArea {
        id: touch_space
        y: 0
        height: 60
        anchors.right: parent.right
        anchors.rightMargin: 136
        anchors.left: parent.left
        anchors.leftMargin: 168

        onPressed: {
			prevX = mouseX;
			prevY = mouseY;
			moving = true;
		}
        onReleased: {
			moving = false
		}
        onMouseXChanged: {
			if (moving && parentWindow !== null && !parentMaximized){
				var dx = mouseX-prevX
				parentWindow.setX(parentWindow.x+dx)
			}
		}
        onMouseYChanged:{
			if (moving && parentWindow !== null && !parentMaximized){
				var dy = mouseY-prevY
				parentWindow.setY(parentWindow.y+dy)
			}
		}
        onDoubleClicked: {
			if(parentWindow !== null){
				if(parentMaximized){
					parentWindow.showNormal()
				}else{
					parentWindow.showMaximized()
				}
				parentMaximized = !parentMaximized;
			}
		}
    }
}









/*##^## Designer {
    D{i:2;anchors_x:8;anchors_y:8}D{i:3;anchors_x:39}
}
 ##^##*/
