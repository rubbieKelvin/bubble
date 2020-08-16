import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import QtQuick.Dialogs 1.0
import QtQuick.Controls.Material 2.0
import "src/js/app.js" as App
import "src/qml"

ApplicationWindow{
	id: root
	width: 1000
	height: 730
	visible: true
	flags: Qt.Window | Qt.FramelessWindowHint
	title: "Bubble"
	color: "#ffffff"

	// states and stuffs
	property bool connected_to_server: false
	property bool server_running: false
	property string server_domain: ""
	property string server_key: ""
	property string connected_domain: ""
	property bool profile_changed: false

	// resizers
	property int right_prevX
	property int left_prevX
	property int bottom_prevY

	// chat data
	property string current_chat_id: ""
	property string current_chat_name: ""
	property string notification: ""
	property string notify_tip: ""

	// profile
	property string username: ""
	property string usermail: ""
	property string userphone: ""
	property string useravatar: "0"
	property string my_id: ""

	// client signals
	signal clientErrorOccured(string errormessage)
	signal clientConnectedChanged(bool connected)
	signal clientHandshakeEnded(bool result)
	signal clientContactUpdated(string contacts)
	signal clientMsgRecv(string data)
	signal threadedProcessStarted(string title)
	signal threadedProcessEnded(bool successful)

	// server signals
	signal serverRunningChanged(bool running)

	// user signals
	signal userNameChanged(string name)
	signal userAvatarChanged(string avatar)

	function show_notification(message) {
	// functions
	    // body...
		notif_bg.color = "#EB5757";
		notify_tip = message;
	}

	function clear_notification(argument) {
		notif_bg.color = "#00000000"
	    notification = "";
		notify_tip = "";
	}

	function showProfile(sender){
		let c = client.get_contact_by_id(sender);
		c = JSON.parse(c);
		let avatar = user.get_avatar_by_id(c.avatar);
		avatar = JSON.parse(avatar);

		profile_label.text = c.name;
		phone_label.text = c.phone;
		mail_label.text = c.mail;
		other_profile_img.source = "res/images/avatars/"+avatar.source;

		if (right_rect.width == 0){
			r_drawer_anim.to = 250;
		}else if (right_rect.width == 250){
			r_drawer_anim.to = 0;
		}

		// lists
		let media_data = binarystore.filter(sender, "MEDIA");
		media_model.clear();

		for (let i=0; i<media_data.length; i++){
			let curr = media_data[i];
			let is_img = files.is_image(curr.file)
			media_model.append({i_file:curr.file, i_source:(is_img)?curr.file:"res/images/file.png"})
		}

		let doc_data = binarystore.filter(sender, "DOCUMENT")
		doc_model.clear();

		for (let q=0; q<doc_data.length; q++){
			let qurr = doc_data[q];
			doc_model.append({i_file:qurr.file})
		}

		r_drawer_anim.restart();
	}

	Material.accent: App.Colors.primary

	// font used for this project
	FontLoader {
		id: montserrat
		source: "res/fonts/Montserrat/Montserrat-Regular.ttf"
	}

	// for binary data storage
	BinaryStore{id: binarystore}

	// when this component is done loaded...
	Component.onCompleted: {
		main.currentIndex = 0;
		root.showMaximized()

		// set client profile
		let name = user.name;
		let mail = user.mail;
		let phone = user.phone;
		let avatar = user.avatar;
		let m_id = client.my_id();

		client.set_profile("name", name);
		client.set_profile("mail", mail);
		client.set_profile("phone", phone);
		client.set_profile("avatar", avatar);

		username = name;
		usermail = mail;
		userphone = phone;
		useravatar = avatar;
		my_id = m_id;

		let avatar_ = user.get_avatar_by_id(avatar);
		avatar_ = JSON.parse(avatar_);
		image_user.source = "res/images/avatars/"+avatar_.source;
		image5_user.source = "res/images/avatars/"+avatar_.source;

		// client signal bindings
		client.error.connect(clientErrorOccured)
		client.connectedChanged.connect(clientConnectedChanged)
		client.handshakeEnded.connect(clientHandshakeEnded)
		client.contactsUpdated.connect(clientContactUpdated)
		client.messageRecieved.connect(clientMsgRecv)
		client.threadedProcessStarted.connect(threadedProcessStarted)
		client.threadedProcessEnded.connect(threadedProcessEnded)

		// server signal bindings
		server.runningChanged.connect(serverRunningChanged)

		// user signal bindings
		user.nameChanged.connect(userNameChanged)
		user.avatarChanged.connect(userAvatarChanged)
	}


	Connections{
		target: root

		onClosing:{
			client.close()
			server.close()
			user.save()
		}

		onThreadedProcessStarted:{
			thread_mill.text = title;
			thread_mill_dialog.open()
		}

		onThreadedProcessEnded:{
			thread_mill_dialog.close()
		}

		onClientErrorOccured:{
			// error_msg.text = errormessage;
			// error_msg.visible = true;
			// login_button.running = false;

			console.log(errormessage);

			if (errormessage === "no connection could be made because host doesnt exist"){
				login_button.show_error("workspace doesnt exist")
			}
		}

		onClientConnectedChanged:{
			connected_to_server = connected;
			if(connected){
				login_button.running = false;
				if (server_running){
					main.currentIndex = 3;
				}else{
					main.currentIndex = 1;
				}
			}else{
				main.currentIndex = 2;
				contact_model.clear();
			}
		}

		onClientContactUpdated:{
			contacts = JSON.parse(contacts);
			contact_model.clear();
			contact_model.append({
				i_descr: "connection established",
				i_name: connected_domain,
				i_time: "Just now",
				i_id: "*",
				i_avatar: "70"
			});
			for (let i=0; i<contacts.length; i++){
				let contact = contacts[i];
				if (contact.id !== my_id){
					contact_model.append({
						i_descr: "connection established",
						i_name: contact.name,
						i_time: "Just now",
						i_id: contact.id,
						i_avatar: contact.avatar
					});
				}
			}

			// ListElement{
			// 	i_source: "res/images/temp/g1.png"
			// 	i_descr: "somthing happening :) :)"
			// 	i_name: "Jenny adein"
			// 	i_time: "22:00"
			// }
		}

		onClientHandshakeEnded:{
			if (!result){
				// error_msg.text = "Could not access network";
				// error_msg.visible = true;
				login_button.show_error("Could not access network");
				login_button.running = false;
			}
		}

		onClientMsgRecv:{
			let msg = JSON.parse(data);
			let is_curr = (msg.sender == current_chat_id);
			if (!is_curr && (msg.sender !== my_id)){
				notification = msg.sender;
				show_notification(msg.body);
			}
			App.showMsg(data, current_chat_id, my_id, msg_model);
		}

		onServerRunningChanged:{
			server_running = running;
		}

		onUserNameChanged:{
			// username = name;
			root.username = name;
			username_label_1.text = name;
		}

		onUserAvatarChanged:{
			root.useravatar = avatar;
			let avatar_ = user.get_avatar_by_id(avatar);
			avatar_ = JSON.parse(avatar_);

			image_user.source = "res/images/avatars/"+avatar_.source;
			image5_user.source = "res/images/avatars/"+avatar_.source;
		}
	}

	// window manager bar. at the top of the application
	WMBar{
		id: wmbar
		anchors.top: parent.top
		anchors.topMargin: 0
		anchors.right: parent.right
		anchors.rightMargin: 0
		anchors.left: parent.left
		anchors.leftMargin: 0
		parentWindow: root
	}

	// stack layout for the application
	StackLayout {
		id: main
		currentIndex: 2
		anchors.right: parent.right
		anchors.rightMargin: 0
		anchors.left: parent.left
		anchors.leftMargin: 0
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 0
		anchors.top: wmbar.bottom
		anchors.topMargin: 0

		// intro page... only shows the intro animation and intro shits
		Page {
			id: intro
			width: parent.width
			height: parent.height
			enabled: (main.currentIndex==0)

			Rectangle{
				id: rectangle
				anchors.fill: parent

				Image {
					id: image
					x: 450
					y: 240
					anchors.horizontalCenter: parent.horizontalCenter
					fillMode: Image.PreserveAspectFit
					source: "res/images/bubble.png"
				}

				Label {
					x: 458
					y: 364
					width: 92
					height: 26
					text: root.title
					anchors.horizontalCenter: parent.horizontalCenter
					verticalAlignment: Text.AlignVCenter
					font.weight: Font.Medium
					font.pixelSize: 18
					font.family: montserrat.name
					horizontalAlignment: Text.AlignHCenter
					color: App.Colors.grey4
				}

				Label {
					x: 524
					y: 644
					width: 134
					height: 18
					text: qsTr("stuffs by rubbie")
					font.family: montserrat.name
					color: App.Colors.grey3
					anchors.horizontalCenter: parent.horizontalCenter
					horizontalAlignment: Text.AlignHCenter
				}

				ProgressBar {
					indeterminate: true
					anchors.right: parent.right
					anchors.rightMargin: 0
					anchors.left: parent.left
					anchors.leftMargin: 0
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 0
					value: 0.5
					Material.accent: App.Colors.primary
				}

				Timer{
					interval: 5000
					running: true
					onTriggered: {
						// check for connectivity here
						// connect_dia.open()
						main.currentIndex = 2
					}
				}
			}
		}

		// chat space... where the main thing happens
		Page{
			id: space
			height: parent.height
			width: parent.width
			enabled: (main.currentIndex==1)

			Rectangle{
				id: rectangle2
				anchors.fill: parent

				// ......
				// ......
				// left rect, showing contact, nav, settings, profile pages
				// ......
				// ......

				Rectangle {
					id: left_rect
					width: 200
					color: "#ffffff"
					anchors.top: parent.top
					anchors.topMargin: 0
					anchors.left: parent.left
					anchors.leftMargin: 0
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 0

					StackLayout {
						id: left_stack
						width: 170
						anchors.fill: parent
						currentIndex: 2

						Component.onCompleted: currentIndex=0

						NumberAnimation{
							id: nav_resize_anim
							target: left_rect
							property: "width"
							duration: 500
							easing.type: Easing.InOutQuad
						}

						Page {
							id: nav_page
							width: parent.width
							height: parent.height
							enabled: (left_stack.currentIndex == 0)

							Rectangle {
								id: nav_rect
								color: "#3356ccf2"
								anchors.fill: parent

								RowLayout {
									x: 11
									y: 30
									width: 181
									height: 50
									anchors.horizontalCenterOffset: 2
									anchors.horizontalCenter: parent.horizontalCenter

									Image {
										id: image_user
										height: 45
										Layout.preferredHeight: 45
										Layout.preferredWidth: 45
										fillMode: Image.PreserveAspectCrop
									}

									Label {
										id: username_label_1
										color: App.Colors.grey3
										font.pixelSize: 12
										font.weight: Font.Medium
										font.family: montserrat.name
										Layout.preferredHeight: 45
										Layout.preferredWidth: 131
										verticalAlignment: Text.AlignVCenter

										Component.onCompleted:{
											text = username;
										}
									}
								}

								Label {
									id: label6
									x: 11
									y: 675
									color: App.Colors.grey3
									text: qsTr("stuffs by rubbie")
									anchors.bottom: parent.bottom
									anchors.bottomMargin: 11
									font.pixelSize: 8
									font.family: montserrat.name
									anchors.horizontalCenter: parent.horizontalCenter
									horizontalAlignment: Text.AlignHCenter
									verticalAlignment: Text.AlignVCenter
								}

								ColumnLayout {
									x: 0
									y: 165
									width: parent.width
									height: 160
									anchors.verticalCenterOffset: -82
									anchors.verticalCenter: parent.verticalCenter

									NavButton{
										id: profile_nav
										width: 200
										title: "Profile"
										Layout.fillWidth: true
										image.source: (!selected)?"res/images/profile.png":"res/images/profile_selected.png"

										onSelectedClicked:{

										}

										onSelectedModeChanged:{
											if(state){
												message_nav.set_state(false);
												settings_nav.set_state(false);

												// shoot out this stack and change to profile
												nav_resize_anim.to = 280;
												if (!nav_resize_anim.running){
													nav_resize_anim.start()
												}
												left_stack.currentIndex = 1;
											}
										}
									}

									NavButton {
										id: message_nav
										width: 200
										title: "Messages"
										Layout.fillWidth: true
										image.source: (!selected)?"res/images/mail.png":"res/images/mail_selected.png"
										selected: true

										onSelectedClicked:{

										}

										onSelectedModeChanged:{
											if (state){
												profile_nav.set_state(false);
												settings_nav.set_state(false);
												// shoot out contact bar
												contact_toggler_anim.to = 280;
												if (!contact_toggler_anim.running){
													contact_toggler_anim.start()
												}
											}else{
												// shoot in contact bar
												contact_toggler_anim.to = 0;
												if (!contact_toggler_anim.running){
													contact_toggler_anim.start()
												}
											}
										}
									}

									NavButton {
										id: settings_nav
										width: 200
										title: "Settings"
										Layout.fillWidth: true
										image.source: (!selected)?"res/images/settings.png":"res/images/settings_selected.png"

										onSelectedClicked:{

										}

										onSelectedModeChanged:{
											if (state){
												message_nav.set_state(false);
												profile_nav.set_state(false);

												// shoot out this stack and change to profile
												nav_resize_anim.to = 280;
												if (!nav_resize_anim.running){
													nav_resize_anim.start()
												}
												left_stack.currentIndex = 2;
											}
										}
									}
								}
							}
						}

						Page {
							id: profile_page
							width: parent.width
							height: parent.height
							enabled: (left_stack.currentIndex == 1)

							Rectangle {
								id: rectangle3
								color: App.Colors.grey8
								anchors.fill: parent

								RowLayout {
									y: 26
									height: 18
									anchors.left: parent.left
									anchors.leftMargin: 8
									anchors.right: parent.right
									anchors.rightMargin: 8

									Image {
										fillMode: Image.PreserveAspectFit
										source: "res/images/cancel 1.png"

										MouseArea {
											anchors.fill: parent
											cursorShape: Qt.PointingHandCursor
											onClicked: {
												// shoot left rect bact in and change to message view
												// shoot out this stack and change to profile
												nav_resize_anim.to = 200;
												if (!nav_resize_anim.running){
													nav_resize_anim.start()
												}
												left_stack.currentIndex = 0;
												message_nav.set_state(true);

												if (profile_changed){
													client.serve_updated_profile();
													profile_changed = false;
												}else{

												}
											}
										}
									}

									Label {
										color: App.Colors.grey2
										text: qsTr("Profile View")
										horizontalAlignment: Text.AlignRight
										Layout.fillWidth: true
										Layout.preferredHeight: 18
										font.weight: Font.Medium
										font.pixelSize: 12
										font.family: montserrat.name
										verticalAlignment: Text.AlignVCenter
									}
								}

								Image {
									id: image5_user
									x: 43
									y: 80
									width: 100
									height: 100
									anchors.horizontalCenter: parent.horizontalCenter
									fillMode: Image.PreserveAspectCrop

									MouseArea{
										anchors.fill: parent
										hoverEnabled: false
										cursorShape: Qt.PointingHandCursor

										onClicked:{
											avatar_menu.open()
										}
									}
								}

								TextField {
									id: label7
									y: 191
									height: 30
									color: App.Colors.grey1
									text: username
									topPadding: 3
									bottomPadding: 3
									anchors.right: parent.right
									anchors.rightMargin: 13
									anchors.left: parent.left
									anchors.leftMargin: 13
									font.pixelSize: 12
									font.family: montserrat.name
									font.capitalization: Font.Capitalize
									horizontalAlignment: Text.AlignHCenter
									verticalAlignment: Text.AlignVCenter
									background: Rectangle{
										color: "#00000000"
									}

									onAccepted:{
										let former = user.name;

										if (text.length < 2){
											label7.text = fomer;
										}else{
											profile_changed = true;
											user.set_name(text);
											username = text;
											client.set_profile("name", text);
										}
									}
								}

								Label {
									id: label8
									y: 225
									width: 184
									height: 17
									color: App.Colors.grey3
									text: qsTr("profile")
									font.capitalization: Font.SmallCaps
									font.family: montserrat.name
									font.pixelSize: 12
									anchors.left: parent.left
									anchors.leftMargin: 8
								}

								Rectangle {
									id: rectangle10
									y: 250
									height: 40
									color: "#00000000"
									anchors.right: parent.right
									anchors.rightMargin: 8
									anchors.left: parent.left
									anchors.leftMargin: 8

									Image {
										x: 7
										y: 7
										anchors.verticalCenter: parent.verticalCenter
										fillMode: Image.PreserveAspectFit
										source: "res/images/profile_phone.png"
									}

									TextField {
										id: profile_pone_label
										y: 8
										height: 40
										color: App.Colors.grey1
										text: userphone
										anchors.right: parent.right
										anchors.rightMargin: 0
										anchors.verticalCenter: parent.verticalCenter
										anchors.left: parent.left
										anchors.leftMargin: 30
										bottomPadding: 3
										topPadding: 3
										font.pixelSize: 10
										font.family: montserrat.name
										verticalAlignment: Text.AlignVCenter
										background: Rectangle{
											color: "#00000000"
										}

										onAccepted:{
											let former = user.phone;

											if (text.length < 2){
												profile_pone_label.text = fomer;
											}else{
												profile_changed = true;
												user.set_phone(text);
												userphone = text;
												client.set_profile("phone", text);
											}
										}
									}
								}

								Rectangle {
									id: rectangle11
									y: 302
									height: 40
									color: "#00000000"
									anchors.right: parent.right
									anchors.rightMargin: 8
									anchors.left: parent.left
									anchors.leftMargin: 8

									Image {
										x: 7
										y: 7
										anchors.verticalCenter: parent.verticalCenter
										fillMode: Image.PreserveAspectFit
										source: "res/images/profile_mail.png"
									}

									TextField {
										id: profile_email_label
										y: 8
										height: 40
										color: App.Colors.grey1
										text: usermail
										anchors.left: parent.left
										anchors.leftMargin: 30
										anchors.right: parent.right
										anchors.rightMargin: 0
										bottomPadding: 3
										topPadding: 3
										anchors.verticalCenter: parent.verticalCenter
										font.pixelSize: 10
										font.family: montserrat.name
										verticalAlignment: Text.AlignVCenter
										background: Rectangle{
											color: "#00000000"
										}

										onAccepted:{
											let former = user.mail;

											if (text.length < 2){
												profile_email_label.text = fomer;
											}else{
												profile_changed = true;
												user.set_mail(text);
												usermail = text;
												client.set_profile("mail", text);
											}
										}
									}
								}
							}
						}

						Page {
							id: settings_page
							width: parent.width
							height: parent.height
							enabled: (left_stack.currentIndex == 2)

							Rectangle {
								id: rectangle7
								color: "#ffffff"
								anchors.fill: parent

								RowLayout {
									y: 26
									height: 18
									anchors.left: parent.left
									anchors.leftMargin: 8
									anchors.right: parent.right
									anchors.rightMargin: 8

									Image {
										fillMode: Image.PreserveAspectFit
										source: "res/images/cancel 1.png"

										MouseArea {
											anchors.fill: parent
											cursorShape: Qt.PointingHandCursor
											onClicked: {
												// shoot left rect bact in and change to message view
												// shoot out this stack and change to profile
												nav_resize_anim.to = 200;
												if (!nav_resize_anim.running){
													nav_resize_anim.start()
												}
												left_stack.currentIndex = 0;
												message_nav.set_state(true);
											}
										}
									}

									Label {
										color: App.Colors.grey2
										text: qsTr("Settings")
										horizontalAlignment: Text.AlignRight
										Layout.fillWidth: true
										Layout.preferredHeight: 18
										font.weight: Font.Medium
										font.pixelSize: 12
										font.family: montserrat.name
										verticalAlignment: Text.AlignVCenter
									}
								}

								ScrollView {
									id: scrollView3
									height: 200
									anchors.left: parent.left
									anchors.leftMargin: 0
									anchors.right: parent.right
									anchors.rightMargin: 0
									anchors.bottom: parent.bottom
									anchors.bottomMargin: 0
									anchors.top: parent.top
									anchors.topMargin: 50

									ListView {
										id: settingslist
										anchors.fill: parent
										delegate: SwitchDelegate {
											id: switchDelegate
											text: qsTr(i_text)
											width: parent.width
											Material.accent: "#6FCF97"
											font.pixelSize: 10
											font.family: montserrat.name
											font.weight: Font.Normal
											Material.foreground: App.Colors.grey1
										}
										model: ListModel{
											ListElement{
												i_text: "enable sounds"
											}
											ListElement{
												i_text: "enable system tray"
											}
										}
									}
								}

								TextField {
									id: textField_for_sec_key
									y: 649
									width: 184
									height: 43
									text: server_key
									anchors.bottom: parent.bottom
									anchors.bottomMargin: 8
									anchors.left: parent.left
									anchors.leftMargin: 8
									anchors.right: parent.right
									anchors.rightMargin: 8
									visible: server_running
									font.weight: Font.Normal
									font.pixelSize: 15
									font.family: montserrat.name
									background:Rectangle{
										color: "#00000000"
									}
									onTextChanged: {
										this.text = server_key
									}
								}
							}
						}
					}
				}


				// ......
				// ......
				// middle space for chatting
				// ......
				// ......

				Rectangle {
					id: contact_rect
					width: 280
					color: "#fefefe"
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 0
					anchors.top: parent.top
					anchors.topMargin: 0
					anchors.left: left_rect.right
					anchors.leftMargin: 0
					clip: true

					NumberAnimation{
						id: contact_toggler_anim
						target: contact_rect
						property: "width"
						duration: 500
						easing.type: Easing.InOutQuad
					}

					Label {
						y: 24
						width: 142
						height: 20
						color: App.Colors.grey1
						text: qsTr("My Messages")
						anchors.left: parent.left
						anchors.leftMargin: 8
						font.weight: Font.Medium
						font.pixelSize: 15
						font.family: montserrat.name
					}

					TextField {
						id: search_contact_input
						y: 55
						height: 43
						text: qsTr("")
						leftPadding: 25
						rightPadding: 0
						placeholderText: "Search Contacts..."
						font.pixelSize: 12
						font.family: montserrat.name
						bottomPadding: 8
						anchors.right: parent.right
						anchors.rightMargin: 8
						anchors.left: parent.left
						anchors.leftMargin: 8
						Material.foreground: App.Colors.grey2
						background: Rectangle{
							color: "#00000000"
						}

						Image {
							id: image1
							y: 0
							anchors.left: parent.left
							anchors.leftMargin: 0
							anchors.verticalCenter: parent.verticalCenter
							fillMode: Image.PreserveAspectFit
							source: "res/images/search.png"
						}
					}

					ScrollView {
						id: scrollView2
						anchors.top: parent.top
						anchors.topMargin: 106
						anchors.right: parent.right
						anchors.bottom: parent.bottom
						anchors.left: parent.left

						ListView {
							id: contact_list
							clip: true
							anchors.fill: parent
							delegate: ContactItem{
								width: parent.width
								contactname: i_name
								contactdescr: i_descr
								time: i_time
								c_id: i_id
								avatar: i_avatar

								onOpenContact:{
									middle_stack.currentIndex = 1;
									current_chat_id = c_id;
									current_chat_name = contactname;
									App.loadChat(current_chat_id, msg_model);
								}
							}
							model: ListModel{id: contact_model}
						}
					}

				}

				Rectangle {
					id: middle_rect
					color: "#ffffff"
					anchors.left: contact_rect.right
					anchors.leftMargin: 0
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 0
					anchors.top: parent.top
					anchors.topMargin: 0
					anchors.right: right_rect.left
					anchors.rightMargin: 0

					StackLayout {
						id: middle_stack
						anchors.fill: parent
						currentIndex: 1

						Component.onCompleted: currentIndex=0;

						Page {
							id: empty_page
							width: parent.width
							height: parent.height

							Rectangle {
								id: rectangle1
								anchors.fill: parent
								color: "#ffffff"

								Image {
									x: 175
									y: 162
									anchors.horizontalCenter: parent.horizontalCenter
									fillMode: Image.PreserveAspectFit
									source: "res/images/welcome_img.png"
								}

								Label {
									x: 258
									y: 372
									width: 232
									height: 22
									color: App.Colors.grey1
									text: qsTr("Welcome to Bubble")
									horizontalAlignment: Text.AlignHCenter
									font.weight: Font.Medium
									font.pixelSize: 16
									font.family: montserrat.name
									anchors.horizontalCenter: parent.horizontalCenter
								}

								Label {
									id: label5
									x: 252
									y: 413
									width: 233
									height: 45
									color: App.Colors.grey3
									text: qsTr("select A contAct on the side bAr to get stArted")
									font.pixelSize: 14
									font.family: montserrat.name
									horizontalAlignment: Text.AlignHCenter
									verticalAlignment: Text.AlignVCenter
									wrapMode: Text.WordWrap
									font.capitalization: Font.AllLowercase
									anchors.horizontalCenter: parent.horizontalCenter
								}

								RoundButton {
									id: help_fab
									x: 494
									y: 644
									text: "?"
									anchors.right: parent.right
									anchors.rightMargin: 8
									anchors.bottom: parent.bottom
									anchors.bottomMargin: 8
									Material.foreground: "#ffffff"
									Material.background: App.Colors.primary
								}
							}
						}

						Page {
							id: chat_page
							width: parent.width
							height: parent.height
							enabled: (middle_stack.currentIndex==1)

							Rectangle{
								id: rectangle4
								anchors.fill: parent
								color: "#ffffff"

								RowLayout {
									y: 24
									height: 48
									anchors.right: parent.right
									anchors.rightMargin: 8
									anchors.left: parent.left
									anchors.leftMargin: 8

									Label {
										id: contact_name
										color: App.Colors.grey4
										text: current_chat_name
										font.capitalization: Font.Capitalize
										Layout.fillHeight: true
										Layout.fillWidth: true
										Layout.preferredHeight: 35
										Layout.preferredWidth: 315
										verticalAlignment: Text.AlignVCenter
										font.weight: Font.Medium
										font.pixelSize: 15
										font.family: montserrat.name

										MouseArea{
											anchors.fill: parent
											cursorShape: Qt.PointingHandCursor

											onClicked:{
												showProfile(current_chat_id);
											}
										}
									}

									Rectangle{
										id: notif_bg
										height: 35
										width: 35
										color: "#00000000"

										ToolTip.visible:(notification !== "")
									    ToolTip.delay: 100
									    ToolTip.timeout: 5000
									    ToolTip.text: "notify_tip"

										Image {
											width: 30
											height: 30
											fillMode: Image.PreserveAspectFit
											source: "res/images/notification_bell.png"
											anchors.fill: parent

										}

										MouseArea {
											anchors.fill: parent
											cursorShape: Qt.PointingHandCursor
											hoverEnabled: false
											onClicked: {
												if (notification !== ""){
													current_chat_id = notification;
													App.loadChat(notification, msg_model);
													clear_notification();
												}
											}
										}
									}

									RoundButton {
										id: compose_btn
										text: "compose"
										Layout.preferredHeight: 48
										Layout.preferredWidth: 113
										font.capitalization: Font.AllLowercase
										font.weight: Font.Medium
										font.pixelSize: 12
										font.family: montserrat.name
										icon.source: "res/images/compose_add.png"
										Material.background: App.Colors.primary
										Material.foreground: "#ffffff"
									}
								}

								ScrollView {
									anchors.bottom: rectangle5.top
									anchors.right: parent.right
									anchors.left: parent.left
									anchors.top: parent.top
									anchors.bottomMargin: 0
									anchors.topMargin: 86

									ListView {
										id: msg_list
										clip: true
										delegate: Message{
											width: parent.width
											message: i_message
											sender: i_sender
											time: i_time
											m_id: i_id
											binary: i_binary

											// Component.onCompleted: bubble.debug(JSON.stringify(i_binary));

											onRequestProfile:{
												// opening will be to 250
												showProfile(sender);
											}

											onPopped:{
												file_popup.file = file;
												file_popup.path = path;
												file_popup_dialog.open();
											}

											onBinaryAdded:{
												binarystore.newbinary(sender, path);
											}
										}
										model:ListModel{id:msg_model}

										onCountChanged: {
											msg_list.currentIndex = count - 1;
										}
									}
								}


								Rectangle {
									id: rectangle5
									y: 597
									height: 90
									color: "#ffffff"
									anchors.right: parent.right
									anchors.rightMargin: 0
									anchors.left: parent.left
									anchors.leftMargin: 0
									anchors.bottom: parent.bottom
									anchors.bottomMargin: 0

									Rectangle {
										id: rectangle6
										y: 0
										height: 45
										color: "#19bdbdbd"
										anchors.right: parent.right
										anchors.rightMargin: 16
										anchors.left: parent.left
										anchors.leftMargin: 16
										anchors.verticalCenter: parent.verticalCenter

										TextField {
											id: message_input
											text: qsTr("")
											leftPadding: 10
											anchors.right: parent.right
											anchors.rightMargin: 135
											anchors.bottomMargin: 0
											anchors.topMargin: 0
											font.pixelSize: 12
											anchors.bottom: parent.bottom
											anchors.left: parent.left
											anchors.top: parent.top
											placeholderText: "Write a reply..."
											bottomPadding: 8
											anchors.leftMargin: 0
											font.weight: Font.Normal
											font.family: montserrat.name
											Material.foreground: App.Colors.grey4
											background: Rectangle{
												color: "#00000000"
											}

											onAccepted:{
												let to = current_chat_id;
												let body = message_input.text;

												App.sendMessage(to, body);
												message_input.text = "";
											}
										}

										RowLayout {
											x: 349
											y: 0
											anchors.right: parent.right
											anchors.rightMargin: 0
											spacing: 0

											CstButton{
												id: clip_btn
												Layout.preferredHeight: 45
												Layout.preferredWidth: 45
												virt_height: 24
												virt_width: 24
												icon.source: "res/images/clip.png"

												onBtnClicked:{
													binary_dialog.open()
												}
											}

											CstButton{
												id: send_btn
												virt_height: 24
												virt_width: 24
												color: App.Colors.primary
												Layout.preferredHeight: 45
												Layout.preferredWidth: 45
												icon.source: "res/images/send.png"

												onBtnClicked:{
													let to = current_chat_id;
													let body = message_input.text;

													App.sendMessage(to, body);
													message_input.text = "";
												}
											}
										}
									}
								}
							}
						}
					}
				}


				Rectangle {
					id: right_rect
					x: 750
					width: 0
					color: App.Colors.grey7
					clip: true
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 0
					anchors.top: parent.top
					anchors.topMargin: 0
					anchors.right: parent.right
					anchors.rightMargin: 0

					RowLayout {
						x: 28
						y: 24
						width: 234
						height: 18
						anchors.horizontalCenter: parent.horizontalCenter

						Label {
							color: App.Colors.grey2
							text: qsTr("Profile View")
							Layout.fillWidth: true
							Layout.preferredHeight: 18
							verticalAlignment: Text.AlignVCenter
							font.weight: Font.Medium
							font.pixelSize: 12
							font.family: montserrat.name
						}

						Image {
							id: close_profile_win
							source: "res/images/cancel 1.png"
							fillMode: Image.PreserveAspectFit

							MouseArea {
								id: close_profile_win_mouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor

								onClicked:{
									// closing
									// opening will be to 250
									r_drawer_anim.to = 0;
									if (!r_drawer_anim.running){
										r_drawer_anim.start()
									}
								}
							}


							NumberAnimation {
								id: r_drawer_anim
								target: right_rect
								property: "width"
								duration: 500
								easing.type: Easing.InOutQuad
							}
						}
					}

					Rectangle{
						x: 75
						y: 80
						width: 100
						height: 100
						anchors.horizontalCenter: parent.horizontalCenter
						radius: 50
						clip: true

						Image {
							id: other_profile_img
							fillMode: Image.PreserveAspectCrop
							anchors.fill: parent
							clip: true
						}
					}

					Label {
						id: profile_label
						x: 112
						y: 203
						width: 234
						height: 31
						color: App.Colors.grey1
						font.weight: Font.Medium
						font.pixelSize: 12
						font.family: montserrat.name
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						anchors.horizontalCenter: parent.horizontalCenter
					}

					Label {
						id: label1
						x: 8
						y: 234
						width: 234
						height: 28
						color: App.Colors.grey3
						text: qsTr("PROFILE")
						font.capitalization: Font.AllUppercase
						verticalAlignment: Text.AlignVCenter
						font.family: montserrat.name
						font.pixelSize: 10
					}

					RowLayout {
						x: 28
						y: 265
						width: 234
						height: 30
						anchors.horizontalCenter: parent.horizontalCenter

						Image {
							id: image2
							source: "res/images/profile_phone.png"
							fillMode: Image.PreserveAspectFit
						}

						Label {
							id: phone_label
							color: App.Colors.grey1
							font.pixelSize: 10
							font.family: montserrat.name
							verticalAlignment: Text.AlignVCenter
							Layout.fillHeight: true
							Layout.fillWidth: true
						}
					}

					RowLayout {
						x: 28
						y: 303
						width: 234
						height: 30
						anchors.horizontalCenter: parent.horizontalCenter
						Image {
							id: image3
							source: "res/images/profile_mail.png"
							fillMode: Image.PreserveAspectFit
						}

						Label {
							id: mail_label
							color: App.Colors.grey1
							font.pixelSize: 10
							font.family: montserrat.name
							verticalAlignment: Text.AlignVCenter
							Layout.fillWidth: true
							Layout.fillHeight: true
						}
					}

					StackLayout {
						id: media_layout
						y: 380
						height: 320
						anchors.rightMargin: 8
						anchors.leftMargin: 8
						currentIndex: 1
						clip: true
						anchors.bottom: parent.bottom
						anchors.bottomMargin: 0
						anchors.right: parent.right
						anchors.left: parent.left

						Component.onCompleted: currentIndex=0;

						Page {
							width: parent.width
							height: parent.height

							Rectangle {
								width: parent.width
								height: parent.height
								color: "#00000000"

								ScrollView {
									id: scrollView
									anchors.fill: parent

									ListView {
										id: media_list
										x: 0
										y: 0
										spacing: 10
										clip: true
										anchors.fill: parent
										delegate: MediaItem{
											width: parent.width
											image.source: i_source
											file: i_file
										}
										model: ListModel{
											id: media_model
										}
										onCountChanged: {
											media_list.currentIndex = count - 1;
										}
									}
								}
							}
						}

						Page {
							width: parent.width
							height: parent.height

							Rectangle {
								width: parent.width
								height: parent.height
								color: "#00000000"

								ScrollView {
									id: scrollView1
									anchors.fill: parent

									ListView {
										id: doc_list
										x: 0
										y: 0
										spacing: 10
										anchors.fill: parent
										delegate: DocItem{
											width: parent.width
											file: i_file
										}
										model: ListModel{id: doc_model}
										onCountChanged: {
											doc_list.currentIndex = count - 1;
										}
									}
								}
							}
						}

						// Page {
						// 	width: parent.width
						// 	height: parent.height

						// 	Rectangle {
						// 		width: parent.width
						// 		height: parent.height
						// 		color: "#00000000"

						// 		ListView {
						// 			id: link_list
						// 			anchors.fill: parent
						// 			delegate: LinkItem{
						// 				width: parent.width
						// 			}
						// 			model: ListModel{
						// 				id: link_model
						// 			}
						// 		}
						// 	}
						// }
					}

					RowLayout {
						x: 8
						y: 350
						width: 234
						height: 50

						Button {
							id: button
							text: qsTr("media")
							Layout.fillWidth: true
							Layout.preferredHeight: 50
							font.capitalization: Font.AllUppercase
							font.pixelSize: 10
							font.family: montserrat.name
							flat: true
							Material.foreground: (media_layout.currentIndex == 0) ? App.Colors.primary:App.Colors.grey3
							onClicked:{
								media_layout.currentIndex = 0
							}
						}

						Button {
							id: button1
							text: qsTr("Documents")
							Layout.fillWidth: true
							Layout.preferredHeight: 50
							font.family: montserrat.name
							font.pixelSize: 10
							flat: true
							font.capitalization: Font.AllUppercase
							Material.foreground: (media_layout.currentIndex == 1) ? App.Colors.primary:App.Colors.grey3
							onClicked:{
								media_layout.currentIndex = 1
							}
						}

						// Button {
						// 	id: button2
						// 	text: qsTr("links")
						// 	Layout.fillWidth: true
						// 	Layout.preferredHeight: 30
						// 	font.family: montserrat.name
						// 	font.pixelSize: 10
						// 	flat: true
						// 	font.capitalization: Font.AllUppercase
						// 	Material.foreground: (media_layout.currentIndex == 2) ? App.Colors.primary:App.Colors.grey3
						// 	onClicked:{
						// 		media_layout.currentIndex = 2
						// 	}
						// }
					}
				}

			}
		}

		Page {
			id: login_page
			width: parent.width
			height: parent.height

			Rectangle{
				id: rectangle8
				anchors.fill: parent


				Rectangle {
					id: rectangle9
					x: 374
					width: 400
					height: 500
					color: "#00000000"
					anchors.top: parent.top
					anchors.topMargin: 100
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter

					RowLayout {
						x: 74
						y: 8
						anchors.horizontalCenter: parent.horizontalCenter

						Image {
							source: "res/images/bubble-sm.png"
							fillMode: Image.PreserveAspectFit
						}

						Label {
							text: qsTr("Bubble")
							font.pixelSize: 18
							font.family: montserrat.name
							color: "#828282"
						}
					}

					Label {
						id: label9
						x: 160
						y: 86
						width: 282
						height: 32
						text: qsTr("Login to your Work Space")
						anchors.horizontalCenterOffset: 0
						anchors.horizontalCenter: parent.horizontalCenter
						horizontalAlignment: Text.AlignHCenter
						font.family: montserrat.name
						font.pixelSize: 20
						color: "#BDBDBD"
					}

					TextField {
						id: domain_field
						y: 142
						width: 300
						height: 50
						anchors.horizontalCenterOffset: 0
						anchors.horizontalCenter: parent.horizontalCenter
						placeholderText: "Work space domain..."
						font.family: montserrat.name
						font.pixelSize: 14
						color: "#1a1a1a"
						rightPadding: 10
						leftPadding: 10
						background: Rectangle{
							color: "#F2F2F2"
						}
					}

					TextField {
						id: domain_key
						y: 218
						width: 300
						height: 50
						rightPadding: 10
						leftPadding: 10
						anchors.horizontalCenterOffset: 0
						anchors.horizontalCenter: parent.horizontalCenter
						placeholderText: "Work space password..."
						font.family: montserrat.name
						font.pixelSize: 14
						echoMode: TextInput.Password
						color: "#1a1a1a"
						background: Rectangle{
							color: "#F2F2F2"
						}
					}

					Label {
						id: error_msg
						x: 50
						y: 278
						width: 300
						height: 17
						text: qsTr("this is for error messaging")
						font.family: montserrat.name
						font.pixelSize: 12
						color: "#EB5757"
						visible: false
					}

					LoadButton{
						id: login_button
						label: "Login"
						x: 50
						y: 307
						width: 300
						height: 50
						delay_interval: 500

						onTriggered:{
							crt_btn.hide_error()
							login_trigger.restart()
							error_msg.text = "";
							error_msg.visible = false;
						}
					}

					Timer{
						id: login_trigger
						interval: 2000
						onTriggered:{
							// connects to a network
							// ... with domain and key
							// the function returns a Json string
							// {error=<error message>}

							let domain = domain_field.text;
							let key = domain_key.text;
							let res = client.connect(domain, key);

							// now check if client got connected
							// if client got connected, error will be null
							// else an error message
							let data = JSON.parse(res);
							if (data.error === null){
								connected_domain = domain;
								// this one happens when connected event is called.
								// TODO: remove the code below
								// reset loader button states
								// login_button.running = false;
								// main.currentIndex = 1;
							}else{
								// error_msg.text = data.error;
								// error_msg.visible = true;
								login_button.show_error(data.error);
							}
						}
					}

					LoadButton{
						x: 50
						id: crt_btn
						y: 373
						width: 300
						label: qsTr("Create Workspace")
						color: "#333333"
						delay_interval: 500

						onTriggered:{
							login_button.hide_error()
							create_trigger.restart()
						}

						Timer{
							id: create_trigger
							interval: 4000

							onTriggered:{
								// create server connection here
								// a json string is returned showing the connection's
								// key and domain name
								// {error=<error_message>, key=<key>, domaion=<domain>}
								crt_btn.running = false;
								let res = server.create();
								let data = JSON.parse(res);
								if (data.error === null){
									server_domain = data.domain;
									connected_domain = server_domain;
									server_key = data.key;

									console.log("connecting dynamically to "+server_domain)
									client.connect(server_domain, server_key)
								}else{
									// error_msg.text = data.error;
									// error_msg.visible = true;
									crt_btn.show_error(data.error)
								}
							}
						}
					}

					Rectangle {
						x: 61
						y: 365
						width: 280
						height: 1
						color: "#cfcfcf"
					}

					// Label {
					// 	x: 50
					// 	y: 370
					// 	width: 300
					// 	height: 17
					// 	text: qsTr("Create connection instead")
					// 	font.capitalization: Font.AllLowercase
					// 	font.family: montserrat.name
					// 	font.pixelSize: 12
					// 	color: "#56CCF2"

					// 	MouseArea{
					// 		enabled: !login_button.running
					// 		hoverEnabled: true
					// 		cursorShape: Qt.PointingHandCursor
					// 		anchors.fill: parent

					// 		onClicked:{
					// 			// create server connection here
					// 			// a json string is returned showing the connection's
					// 			// key and domain name
					// 			// {error=<error_message>, key=<key>, domaion=<domain>}
					// 			let res = server.create();
					// 			let data = JSON.parse(res);
					// 			if (data.error === null){
					// 				server_domain = data.domain;
					// 				connected_domain = server_domain;
					// 				server_key = data.key;

					// 				console.log("connecting dynamically to "+server_domain)
					// 				client.connect(server_domain, server_key)
					// 			}else{
					// 				error_msg.text = data.error;
					// 				error_msg.visible = true;
					// 			}

					// 		}
					// 	}
					// }
				}

				RoundButton {
					x: 944
					y: 644
					text: "?"
					anchors.right: parent.right
					anchors.rightMargin: 8
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 8
					Material.background: "#333333"
					Material.foreground: "#ffffff"
				}
			}
		}

		Page{
			width: parent.width
			height: parent.height

			Rectangle{
				id: rectangle12
				anchors.fill: parent

				Label{
					x: 342
					y: 503
					width: 534
					height: 49
					color: "#4f4f4f"
					text: "your workspace name is rubbie-io and your workspace key is 1209HJD998S. the password is available for you to copy in “settings”"
					anchors.horizontalCenterOffset: 0
					anchors.horizontalCenter: parent.horizontalCenter
					font.pixelSize: 14
					font.family: montserrat.name
					horizontalAlignment: Text.AlignHCenter
					wrapMode: Text.WordWrap
				}

				LoadButton{
					y: 603
					label: "continue to workspace"
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 49
					anchors.verticalCenterOffset: 236
					anchors.horizontalCenterOffset: 0
					width: 200
					anchors.horizontalCenter: parent.horizontalCenter
					delay_interval: 800

					onTriggered:{
						popin_trigger.restart()
					}

					Timer{
						id: popin_trigger
						interval: 3000
						onTriggered:{
							// if client corresponds with server start up...
							// go to next page,
							// else
							// notify the user that there was a problem
							let connected = client.connected();
							if (connected){
								main.currentIndex = 1;
							}else{
								main.currentIndex = 2;
							}
						}
					}
				}


			    Label {
			        id: label
					x: 330
					y: 458
					width: 364
					height: 34
					color: "#333333"
					text: qsTr("You’ve created a workspace!")
					anchors.horizontalCenterOffset: 0
					font.pixelSize: 20
					font.family: montserrat.name
					anchors.horizontalCenter: parent.horizontalCenter
					horizontalAlignment: Text.AlignHCenter
				}

				Image {
					x: 408
					y: 100
					anchors.horizontalCenter: parent.horizontalCenter
					source: "res/images/profile_data_mk6k 1.png"
					fillMode: Image.PreserveAspectFit
				}
			}
		}
	}

	// dialogs
	Dialog{
		id: avatar_menu
		y: 30
		width: parent.width
		height: parent.height-30
		dim: true
		background:Rectangle{
			color: "#00000000"
			width: parent.width
			height: parent.height

			AvatarMenu{
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter

				onRejected:{
					avatar_menu.close()
				}

				onAccepted:{
					if (this.current_avatar !== null){
						let former = user.avatar;
						if (former !== current_avatar){
							profile_changed = true;
							user.set_avatar(current_avatar);
							useravatar = current_avatar;
							client.set_profile("avatar", current_avatar);
						}
					}

					avatar_menu.close()
				}
			}
		}
	}

	Dialog{
		id: thread_mill_dialog
		width: parent.width
		height: parent.height
		dim: true
		background: Rectangle{
			color: "#00000000"
			width: parent.width
			height: parent.height

			ThreadMill{
				id: thread_mill
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
			}
		}
	}

	Dialog{
		id: file_popup_dialog
		y: 30
		width: parent.width
		height: parent.height-30
		dim: true
		background: Rectangle{
			color: "#00000000"
			width: parent.width
			height: parent.height

			FilePopup{
				id: file_popup
				width: 700
				height: 600
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter

				onRejected:{
					file_popup_dialog.close()
				}

				onDownloadClicked:{

				}

				onShareClicked:{

				}
			}
		}
	}

	Dialog{
		id: file_msg_dialog
		y: 30
		width: parent.width
		height: parent.height-30
		dim: true
		background: Rectangle{
			color: "#00000000"
			width: parent.width
			height: parent.height

			AuxilMsg{
				id: aux_msg
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter

				onRejected:{
					message_input.text = aux_msg.body;
					file_msg_dialog.close()
				}

				onAccepted:{
					let to = current_chat_id;
					let msg = aux_msg.body;
					let file = files.get();		// string: json-string list of files

					file_msg_dialog.close();

					let c_ = JSON.parse(file);
					if (c_.length === 0){
						App.sendMessage(to, msg)
					}else{
						App.sendBinary(to, msg, file)
					}

				}
			}
		}
	}

	FileDialog{
		id: binary_dialog
		// folder: StandardPaths.writableLocation(StandardPaths.DocumentLocation)
		title: "Select file to send"
		nameFilters: "All Files (*.*)"

		onAccepted:{
			// let to = current_chat_id;
			let body = message_input.text;
			let file_ = binary_dialog.fileUrl
			// App.sendBinary(to, body, file_)
			aux_msg.clear_inputs();
			aux_msg.set_body(body);
			aux_msg.set_source_one(file_);
			file_msg_dialog.open();

			message_input.text = "";
		}

		onRejected:{

		}
	}


	// these are the window-resize mouse area
	MouseArea {
		id: leftmouseArea
		width: 1
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 0
		anchors.left: parent.left
		anchors.leftMargin: 0
		anchors.top: wmbar.bottom
		anchors.topMargin: 0
		cursorShape: Qt.SizeHorCursor
		enabled: !wmbar.parentMaximized
		hoverEnabled: true

		onPressed:{
			left_prevX = mouseX;
		}

		onReleased:{

		}

		onMouseXChanged:{
			let dx = mouseX - left_prevX;
			root.setX(root.x + dx);
			root.setWidth(root.width - dx);
		}
	}


	MouseArea {
		id: rightmouseArea
		x: 0
		y: 1
		width: 1
		anchors.right: parent.right
		anchors.rightMargin: 0
		hoverEnabled: true
		anchors.bottomMargin: 0
		anchors.bottom: parent.bottom
		cursorShape: Qt.SizeHorCursor
		anchors.topMargin: 0
		anchors.top: wmbar.bottom
		enabled: !wmbar.parentMaximized
		onPressed:{
			right_prevX = mouseX
		}

		onReleased:{

		}

		onMouseXChanged:{
			let dx = mouseX - right_prevX;
			root.setWidth(root.width + dx);
		}
	}

	MouseArea {
		id: buttommouseArea
		y: 30
		height: 1
		anchors.left: parent.left
		anchors.leftMargin: 0
		hoverEnabled: true
		anchors.bottomMargin: 0
		anchors.bottom: parent.bottom
		cursorShape: Qt.SizeVerCursor
		anchors.rightMargin: 0
		anchors.right: parent.right
		enabled: !wmbar.parentMaximized
		onPressed:{
			bottom_prevY = mouseY;
		}

		onReleased:{

		}

		onMouseYChanged:{
			let dy = mouseY - bottom_prevY;
			root.setHeight(root.height + dy)
		}
	}

	Rectangle{
		id: r__
		color: "#EB5757"
		radius: 5
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 75
		anchors.rightMargin: 15
		height: 40
		width: 220
		visible: (App.APPSTAGE == "DEVELOPMENT")
		enabled: visible

		Label{
			text: "app is still in development stage"
			font.family: montserrat.name
			font.pixelSize: 12
			color: "#ffffff"
			anchors.fill: parent
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
		}

	}

	MouseArea {
		anchors.fill: r__
		hoverEnabled: true
		onEntered: {r__.visible = false}
		onExited: {r__.visible = (App.APPSTAGE == "DEVELOPMENT")}
	}

	// tray


}
