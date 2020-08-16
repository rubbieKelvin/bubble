import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "../js/app.js" as App


Rectangle{
	id: root
	height: 165
	radius: 5
	clip: true
	width: 234
	color: "#00000000"

	property alias image: image
	property string file

	FontLoader {
		id: montserrat
		source: "../../res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	Image {
		id: image
		anchors.fill: parent
		source: "qrc:/qtquickplugin/images/template_image.png"
		fillMode: Image.PreserveAspectFit
	}
}
