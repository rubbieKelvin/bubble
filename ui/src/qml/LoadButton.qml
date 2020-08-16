import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App

// this button is used to show delay after clicking a button

Rectangle{
	id: root
	width: 200
	height: 50
	color: "#56CCF2"
	
	property string label: "Button"
	property bool running: false
	property int delay_interval: 200
	property string error: "Here's an error."
	property string maincolor
	signal triggered()

	Component.onCompleted:{
		maincolor = color;
	}

	function show_error(message){
		let error_color = "#EB5757";
		error = message;
		running = false;
		root.color = error_color;
		error_trigger.restart();
		error_rect.visible = true;
	}

	function hide_error(){
		root.color = maincolor;
		error_rect.visible = false;
		error_trigger.stop();
	}

	Timer{
		id: error_trigger
		interval: 5000

		onTriggered:{
			hide_error();
		}
	}
	
	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}
	
	Rectangle{
		id: overlay_rect
		anchors.fill: parent
		color: "#11000000"
		visible: false
	}
	
	Label{
		id: label_id
		text: label
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		font.family: montserrat.name
		font.pixelSize: 14
		color: "#ffffff"
		width: parent.width
		height: parent.height
		visible: !running
	}
	
	Rectangle{
		width: 20
		height: 30
		color: "#00000000"
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		visible: running
		
		onVisibleChanged: {
			if(visible){
				anim.restart()
			}else{
				anim.stop()
			}
		}
		
		RowLayout {
			anchors.fill: parent
			
			Rectangle{
				id: bud
				radius: 2
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				Layout.preferredHeight: 4
				Layout.preferredWidth: 4
				color: "#ffffff"
				opacity: 0
			}
			
			Rectangle{
				id: bud_2
				radius: 2
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				Layout.preferredHeight: 4
				Layout.preferredWidth: 4
				color: "#ffffff"
				opacity: 0
			}
			
			Rectangle{
				id: bud_3
				radius: 2
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				Layout.preferredHeight: 4
				Layout.preferredWidth: 4
				color: "#ffffff"
				opacity: 1
			}
		}
		
		SequentialAnimation{
			id: anim
			loops: -1
			ParallelAnimation{
				NumberAnimation {
					target: bud
					easing.type: Easing.InQuad 
					properties: "opacity"
					duration: delay_interval
					from: 0
					to: 1
				}
				
				NumberAnimation {
					target: bud_3
					property: "opacity"
					duration: delay_interval
					easing.type: Easing.InQuad
					from: 1
					to: 0
				}
			}
			ParallelAnimation{
				NumberAnimation {
					target: bud_2
					easing.type: Easing.InQuad 
					properties: "opacity"
					duration: delay_interval
					from: 0
					to: 1
				}
				
				NumberAnimation {
					target: bud
					property: "opacity"
					duration: delay_interval
					easing.type: Easing.InQuad
					from: 1
					to: 0
				}	
			}
			ParallelAnimation{
				NumberAnimation {
					target: bud_3
					easing.type: Easing.InQuad 
					properties: "opacity"
					duration: delay_interval
					from: 0
					to: 1
				}
				
				NumberAnimation {
					target: bud_2
					property: "opacity"
					duration: delay_interval
					easing.type: Easing.InQuad
					from: 1
					to: 0
				}
			}
		}
		
	}
	
	Rectangle {
		id: error_rect
		width: 49
		height: 50
		color: "#b3000000"
		visible: false

		ToolTip.visible: error_rect.visible
	    ToolTip.delay: 1000
	    ToolTip.timeout: 7000
	    ToolTip.text: error
		
		Image {
			x: 13
			y: 13
			width: 24
			height: 24
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			source: "../../res/images/alert.png"
			fillMode: Image.PreserveAspectFit
		}
	}
	
	MouseArea {
		hoverEnabled: true
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		
		onEntered: {
			overlay_rect.visible = true
		}
		
		onExited: {
			overlay_rect.visible = false
		}
		onClicked:{
			running = true;
			hide_error()
			triggered();
		}
	}
	
}
