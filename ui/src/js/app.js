// console.log("hello world from js");

let Colors = {
	dark: "#383A40",
	grey1: "#333333",
	grey2: "#4F4F4F",
	grey3: "#828282",
	grey4: "#bdbdbd",
	grey5: "#E0E0E0",
	grey7: "#FAFAFA",
	grey8: "#FCFCFC",
	primary: "#56CCF2",
	document:{
		pdf: "#eb5757",
		doc: "#2D9CDB",
		py: "#F2C94C"
	}
};

let MEDIA_EXTENSIONS = [".png", ".jpeg", ".jpg", ".wav", ".mp3", ".mp4", ".ogg", ".gif"];

const close = (root) => {
	root.close();
}


const sendMessage = (to, message) =>{
	if (message.length > 0){
		client.send(to, message);
	}
}

const loadChat = (chatid, model) => {
	model.clear();
	let chat = client.get_messages(chatid);
	chat = JSON.parse(chat);

	for (let i=0; i<chat.length; i++){
		let msg = chat[i];
		// bubble.debug(JSON.stringify(msg.binaries))
		model.append({
			i_message:msg.body,
			i_sender:msg.sender,
			i_time:msg.time,
			i_id:msg.id,
			i_binary: JSON.stringify(msg.binaries)
		});

	}
}

const showMsg = (data, currentchat, my_id, model) => {
	let msg = JSON.parse(data);
	let is_sender = (msg.sender == my_id);
	if ((msg.to == "*" && currentchat=="*") || is_sender){
		model.append({
			i_message:msg.body,
			i_sender:msg.sender,
			i_time:msg.time,
			i_id:msg.id,
			i_binary: JSON.stringify(msg.binaries)
		});
	} else if (msg.sender == currentchat || is_sender){
		model.append({
			i_message:msg.body,
			i_sender:msg.sender,
			i_time:msg.time,
			i_id:msg.id,
			i_binary: JSON.stringify(msg.binaries)
		});
	}
}

function contact(contact_id){
	let c = client.get_contact_by_id(contact_id);
	c = JSON.parse(c);
	return c
}

const get_all_avatars = () =>{
	let avatars = user.get_all_avatars();
	avatars = JSON.parse(avatars);
	return avatars
}

function range(start, stop, step) {
    if (typeof stop == 'undefined') {
        // one param defined
        stop = start;
        start = 0;
    }

    if (typeof step == 'undefined') {
        step = 1;
    }

    if ((step > 0 && start >= stop) || (step < 0 && start <= stop)) {
        return [];
    }

    var result = [];
    for (var i = start; step > 0 ? i < stop : i > stop; i += step) {
        result.push(i);
    }

    return result;
};

const sendBinary = (to, text, file) =>{
	client.send_binary(to, text, file)
}

const type = (path) => {
	let res = "DOCUMENT";
	for (var i = 0; i < MEDIA_EXTENSIONS.length; i++) {
		if (path.endsWith(MEDIA_EXTENSIONS[i])) {
			res = "MEDIA";
			break;
		}
	}
	return res;
}

const APPSTAGE = "!DEVELOPMENT"
