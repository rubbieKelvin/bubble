import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	width: 500
	height: 500
	color: "#ffffff"
	
	signal rejected()
	signal accepted()
	property var current_avatar: null
	
	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}	
	
	Rectangle {
		id: header
		y: 0
		height: 48
		color: "#4f4f4f"
		anchors.right: parent.right
		anchors.rightMargin: 0
		anchors.left: parent.left
		anchors.leftMargin: 0
		
		Image{
			y: 13
			source: "../../res/images/avatar_cancel.png"
			width: 22
			height: 22
			anchors.left: parent.left
			anchors.leftMargin: 17
			anchors.verticalCenter: parent.verticalCenter
			
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				
				onClicked:{
					rejected()
				}
			}
		}
		
		Image{
			x: 435
			source: "../../res/images/avatar_accept.png"
			width: 22
			height: 22
			anchors.right: parent.right
			anchors.rightMargin: 23
			anchors.verticalCenter: parent.verticalCenter
			y: 13
			
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				
				onClicked:{
					accepted()
				}
			}
		}
		
		Label {
			x: 58
			y: 0
			width: 252
			height: 48
			color: "#ffffff"
			text: qsTr("Choose avatar")
			font.capitalization: Font.Capitalize
			font.pixelSize: 14
			font.family: montserrat.name
			verticalAlignment: Text.AlignVCenter
		}
	}
	
	ScrollView {
		id: scrollView
		anchors.rightMargin: 5
		anchors.leftMargin: 5
		anchors.bottomMargin: 5
		clip: true
		anchors.top: header.bottom
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.topMargin: 5
		contentHeight: element.implicitHeight
		contentWidth: root.width

		Flow {
			id: element
			x: 0
			y: 48
			spacing: 5
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.topMargin: 0
			
			Repeater{
				id: rep
				delegate:Avatar{
					id: avatar_root
					icon.source: "../../res/images/avatars/"+modelData.source
					title: modelData.name
					avatar_key: modelData.key

					onSelected:{
						current_avatar = key;
						if (key === null){

						}else{
							let num = App.range(rep.count);
							for (let i=0; i<num.length; i++){
								let item = rep.itemAt(i);

								if (item!==this){
									item.deselect();
								}
							}
						}
					}
				}
				
				Component.onCompleted:{
					let avatars = App.get_all_avatars();
					rep.model = avatars;
				}
			}
		}
	}
	
}















/*##^## Designer {
    D{i:2;anchors_width:480;anchors_x:0}D{i:9;anchors_height:400;anchors_width:400}D{i:8;anchors_height:200;anchors_width:200}
}
 ##^##*/
