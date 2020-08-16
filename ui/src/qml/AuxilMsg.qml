import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.0
import "../js/app.js" as App


Rectangle{
	id: root
	width: 350
	height: 230
	color: "#ffffff"

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	property string source_one: ""
	property string source_two: ""
	property string source_three: ""
	property string body: msg_body.text
	property int curr_spot: 1

	signal rejected()
	signal accepted()

	function check_type(source) {
		let is_image = files.is_image(source);
		if (is_image){
			return source
		}else{
			return "../../res/images/file.png";
		}
	}

	function set_body(text) {
	    // body...
		msg_body.text = text;
	}

	function set_source_one(source) {
	    // body...
		source_one = source;
		source_one_img.source = check_type(source);
	}

	function set_source_two(source) {
	    // body...
		source_two = source;
		source_two_img.source = check_type(source);
	}

	function set_source_three(source) {
	    // body...
		source_three = source;
		source_three_img.source = check_type(source);
	}

	function clear_inputs() {
	    // body...
		msg_body.text = "";

		source_one = "";
		source_two = "";
		source_three = "";

		source_one_img.source = "../../res/images/plus.png";
		source_two_img.source = "../../res/images/plus.png";
		source_three_img.source = "../../res/images/plus.png";

		files.clear();
	}

	Rectangle{
		id: rectangle
		color: "#4F4F4F"
		height: 30
		width: parent.width
		anchors.top: parent.top

		Image{
			width: 15
			fillMode: Image.PreserveAspectFit
			anchors.rightMargin: 15
			anchors.verticalCenter: parent.verticalCenter
			source: "../../res/images/avatar_cancel.png"
			anchors.right: parent.right

			MouseArea {
			    anchors.fill: parent
			    cursorShape: Qt.PointingHandCursor
			    hoverEnabled: false
			    onClicked: rejected()
			}
		}

		Label{
			text: "Send Files"
			anchors.verticalCenter: parent.verticalCenter
			color: "#ffffff"
			x: 15
			font.pixelSize: 13
			font.family: montserrat.name
		}
	}

	TextField{
		id: msg_body
		x: 15
		y: 45
		width: 320
		height: 45
		color: "#4f4f4f"
		font.pixelSize: 12
		font.family: montserrat.name
		placeholderText: "Message body..."
		anchors.horizontalCenter: parent.horizontalCenter
	}

	RowLayout {
		x: 15
		y: 100
		width: 320
		height: 100

		Image {
			id: source_one_img
			clip: true
			Layout.preferredHeight: 100
			Layout.preferredWidth: 100
			fillMode: Image.PreserveAspectFit
			source: "../../res/images/plus.png"

			Rectangle {
				height: 25
				color: "#55000000"
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 0
				anchors.left: parent.left
				anchors.leftMargin: 0
				anchors.right: parent.right
				anchors.rightMargin: 0

				Label {
					text: source_one.split("/").slice(-1)[0]
					color: "#ffffff"
					font.capitalization: Font.AllLowercase
					font.pixelSize: 8
					font.family: montserrat.name
					anchors.rightMargin: 3
					anchors.leftMargin: 3
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					clip: true
				}
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true

				onEntered:{
					overlay1.visible = (source_one !== "");
				}
				onExited:{
					overlay1.visible = false;
				}
				onClicked: {
					curr_spot = 1;
					media_dialog.open()

				}
			}


			Rectangle {
				id: overlay1
				x: 8
				height: 25
				color: "#55000000"
				anchors.top: parent.top
				anchors.topMargin: 0
				anchors.right: parent.right
				anchors.leftMargin: 0
				anchors.left: parent.left
				anchors.rightMargin: 0
				visible: false
				enabled: visible

				Label {
					text: "remove"
					color: "#ffffff"
					font.capitalization: Font.AllLowercase
					font.pixelSize: 8
					font.family: montserrat.name
					anchors.rightMargin: 3
					anchors.leftMargin: 3
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					clip: true
				}

				MouseArea {
				    anchors.fill: parent
				    cursorShape: Qt.PointingHandCursor
					hoverEnabled: true

					onEntered:{
						overlay1.visible = (source_one !== "");
					}
					onExited:{
						overlay1.visible = false;
					}
				    onClicked: {
						source_one = "";
						source_one_img.source = "../../res/images/plus.png";
					}
				}
			}

		}

		Image {
			id: source_two_img
			clip: true
			Layout.preferredHeight: 100
			Layout.preferredWidth: 100
			fillMode: Image.PreserveAspectFit
			source: "../../res/images/plus.png"

			Rectangle {
				height: 25
				color: "#55000000"
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 0
				anchors.left: parent.left
				anchors.leftMargin: 0
				anchors.right: parent.right
				anchors.rightMargin: 0

			    Label {
					text: source_two.split("/").slice(-1)[0]
					color: "#ffffff"
					font.capitalization: Font.AllLowercase
					font.pixelSize: 8
					font.family: montserrat.name
					anchors.rightMargin: 3
					anchors.leftMargin: 3
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					clip: true
			    }
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true

				onEntered:{
					overlay2.visible = (source_two !== "");
				}
				onExited:{
					overlay2.visible = false;
				}
			    onClicked: {
					curr_spot = 2;
					media_dialog.open()
				}
			}

			Rectangle {
				id: overlay2
				x: 8
				height: 25
				color: "#55000000"
				anchors.top: parent.top
				anchors.topMargin: 0
				anchors.right: parent.right
				anchors.leftMargin: 0
				anchors.left: parent.left
				anchors.rightMargin: 0
				visible: false
				enabled: visible

				Label {
					text: "remove"
					color: "#ffffff"
					font.capitalization: Font.AllLowercase
					font.pixelSize: 8
					font.family: montserrat.name
					anchors.rightMargin: 3
					anchors.leftMargin: 3
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					clip: true
				}

				MouseArea {
				    anchors.fill: parent
				    cursorShape: Qt.PointingHandCursor
					hoverEnabled: true

					onEntered:{
						overlay2.visible = (source_two !== "");
					}
					onExited:{
						overlay2.visible = false;
					}
				    onClicked: {
						source_two = "";
						source_two_img.source = "../../res/images/plus.png";
					}
				}
			}

		}

		Image {
			id: source_three_img
			clip: true
			Layout.preferredHeight: 100
			Layout.preferredWidth: 100
			fillMode: Image.PreserveAspectFit
			source: "../../res/images/plus.png"

			Rectangle {
				height: 25
				color: "#55000000"
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 0
				anchors.left: parent.left
				anchors.leftMargin: 0
				anchors.right: parent.right
				anchors.rightMargin: 0

			    Label {
					text: source_three.split("/").slice(-1)[0]
					color: "#ffffff"
					font.capitalization: Font.AllLowercase
					font.pixelSize: 8
					font.family: montserrat.name
					anchors.rightMargin: 3
					anchors.leftMargin: 3
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					clip: true
			    }
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true

				onEntered:{
					overlay3.visible = (source_three !== "");
				}
				onExited:{
					overlay3.visible = false;
				}
			    onClicked: {
					curr_spot = 3;
					media_dialog.open()
				}
			}

			Rectangle {
				id: overlay3
				x: 8
				height: 25
				color: "#55000000"
				anchors.top: parent.top
				anchors.topMargin: 0
				anchors.right: parent.right
				anchors.leftMargin: 0
				anchors.left: parent.left
				anchors.rightMargin: 0
				visible: false
				enabled: visible

				Label {
					text: "remove"
					color: "#ffffff"
					font.capitalization: Font.AllLowercase
					font.pixelSize: 8
					font.family: montserrat.name
					anchors.rightMargin: 3
					anchors.leftMargin: 3
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					clip: true
				}

				MouseArea {
				    anchors.fill: parent
				    cursorShape: Qt.PointingHandCursor
					hoverEnabled: true

					onEntered:{
						overlay3.visible = (source_three !== "");
					}
					onExited:{
						overlay3.visible = false;
					}
				    onClicked: {
						source_three = "";
						source_three_img.source = "../../res/images/plus.png";
					}
				}
			}


		}
	}

	RoundButton {
		id: roundButton
		x: 294
		y: 174
		display: AbstractButton.IconOnly
		Material.foreground: "#ffffff"
		Material.background: "#56CCF2"
		icon.source: "../../res/images/send-sm.png"

		onClicked:{
			if (source_one !== ""){
				files.add(1, source_one);
			}
			if (source_two !== ""){
				files.add(2, source_two);
			}
			if (source_three !== ""){
				files.add(3, source_three)
			}
			accepted()
		}
	}

	FileDialog{
		id: media_dialog
		title: "Select file"
		nameFilters: "All Files (*.*)"

		onAccepted:{
			if (curr_spot === 1){
				set_source_one(fileUrl);
			}else if(curr_spot === 2){
				set_source_two(fileUrl);
			}else if(curr_spot === 3){
				set_source_three(fileUrl);
			}
		}

		onRejected:{

		}
	}

}









/*##^## Designer {
    D{i:9;anchors_width:200}D{i:11;anchors_width:200;anchors_y:3}
}
 ##^##*/
