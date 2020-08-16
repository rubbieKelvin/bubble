import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	width: 600
	height: message_text.contentHeight+element.implicitHeight+55
	color: "#1b1b1b"

	property string message: ""
	property string sender: ""
	property string time: ""
	property string m_id: ""
	property alias rep: rep
	property string binary
	property var contact
	readonly property string cwd: bubble.cwd()

	signal requestProfile(string id)
	signal popped(string path, string file)
	signal binaryAdded(string sender, string path)

	Component.onCompleted:{
		let c = App.contact(sender);
		let avatar = user.get_avatar_by_id(c.avatar);
		let binaries = JSON.parse(binary);

		avatar = JSON.parse(avatar);
		rep.model = binaries;
		bubble.debug(binary)

		root.color = "#00000000"
		sender_text.text = c.name;
		sender_image.source = "../../res/images/avatars/"+avatar.source;
	}

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	MouseArea {
		hoverEnabled: true
		anchors.fill: parent

		onEntered:{
			b_ly.visible = true
		}

		onExited:{
			b_ly.visible = false
		}
	}

	ColumnLayout {
		anchors.rightMargin: 5
		anchors.leftMargin: 5
		anchors.bottomMargin: 5
		anchors.topMargin: 5
		anchors.fill: parent

		RowLayout {
			Layout.preferredHeight: 32
			Layout.preferredWidth: 584

			Rectangle {
				id: rectangle
				color: "#ffffff"
				radius: 15
				Layout.fillHeight: false
				Layout.preferredHeight: 30
				Layout.preferredWidth: 30

				Image {
					id: sender_image
					anchors.fill: parent
					fillMode: Image.PreserveAspectFit
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked:{
						requestProfile(sender);
					}
				}
			}

			ColumnLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.preferredHeight: 28
				Layout.preferredWidth: 419
				spacing: 0

				Label {
					id: sender_text
					color: "#4f4f4f"
					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.preferredHeight: 17
					Layout.preferredWidth: 298
					font.weight: Font.Medium
					font.pixelSize: 12
					font.family: montserrat.name
				}

				Label {
					id: time_text
					color: "#828282"
					text: time
					Layout.fillWidth: true
					Layout.preferredHeight: 11
					Layout.preferredWidth: 298
					font.family: montserrat.name
					font.pixelSize: 8
					font.weight: Font.Normal
				}
			}

			RowLayout {
				id: b_ly
				Layout.fillHeight: true
				visible: false

				Image {
					id: forward
					Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
					Layout.preferredHeight: 18
					Layout.preferredWidth: 18
					source: "../../res/images/arrow-reply.png"
					fillMode: Image.PreserveAspectFit

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
					}
				}

				Image {
					id: delete_
					Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
					Layout.preferredHeight: 18
					Layout.preferredWidth: 18
					source: "../../res/images/trash.png"
					fillMode: Image.PreserveAspectFit

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
					}
				}
			}
		}

		Label {
			id: message_text
			color: "#4f4f4f"
			text: message
			fontSizeMode: Text.Fit
			font.letterSpacing: 1
			lineHeight: 1.2
			font.pixelSize: 12
			font.family: montserrat.name
			wrapMode: Text.WrapAnywhere
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.preferredWidth: 584

		}

		Flow {
			id: element
			Layout.fillHeight: true
			Layout.fillWidth: true
			// Layout.preferredHeight: implicitHeight
			spacing: 5

			Repeater{
				id: rep
				delegate: FileBoxItem{
					id: box
					width: 250
					height: 200

					onClicked: popped(box.path, box.file)

					Component.onCompleted: {
						let is_image = files.is_image(modelData.name+modelData.ext);
						box.file = "file:///"+cwd+"temp/"+modelData.name+modelData.ext;
						if (is_image){
							let src = "file:///"+cwd+"temp/"+modelData.name+modelData.ext;
							box.path = src;
						}else{
							box.path = "../../res/images/file.png";
						}
						binaryAdded(sender, box.file);
					}
				}
			}
		}
	}


}























/*##^## Designer {
    D{i:2;anchors_height:100;anchors_width:100}D{i:6;anchors_height:100;anchors_width:100}
D{i:7;anchors_height:100;anchors_width:100}D{i:3;anchors_x:8;anchors_y:8}
}
 ##^##*/
