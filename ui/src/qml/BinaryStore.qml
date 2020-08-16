import QtQuick 2.6
import "../js/app.js" as App

QtObject{
	id: root
	
	property string data: ""

	function newbinary(sender, path) {
	    // body...
	    let filetype = App.type(path);
	    let chunk = {file:path, type:filetype, sender:sender};

	    if (data !== ""){
	    	let o_data = JSON.parse(data);
	    	o_data.push(chunk);
	    	data = JSON.stringify(o_data);
    	}else{
    		data = JSON.stringify([chunk]);
    	}
	}

	function filter(sender, type){
		if (data === ""){
			return [];
		}else{
			let o_data = JSON.parse(data)
			let res = [];

			for (let i=0; i<o_data.length; i++){
				let curr = o_data[i];

				if (curr.sender === sender && curr.type === type){
					res.push(curr);
				}
			}
			return res;
		}
	}
}
