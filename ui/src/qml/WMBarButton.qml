import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9

Rectangle {
    id: root
    width: 30
    height: 30
    property alias icon: icon
    property string bg: "#33000000"
    property var hover: false
    property string tip: ""
    signal click()

    Component.onCompleted: root.color = "#00000000"
    ToolTip.visible:(hover && tip.length != 0)
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.text: tip

    Image {
        id: icon
        x: 8
        y: 8
        width: 15
        height: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/qtquickplugin/images/template_image.png"
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        id: m_area
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onEntered: {
            root.color = bg
            hover = true
        }
        onExited: {
            root.color = "#00000000"
            hover = false
        }
        onClicked: click()
    }

}
