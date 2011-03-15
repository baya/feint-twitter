
function getQueryParams(query_obj){
    var query_str = "";
    for(var p in query_obj){
        query_str = query_str + p + "=" + query_obj[p] + "&";
    }
    query_str = query_str.replace(/^&|&$/, '');
    return query_str;
}

function getRealTimeStream(interval, base_url, query_obj){
    var query_str = getQueryParams(query_obj);
    var url = encodeURI(base_url + "?" + query_str);
    var interval = interval || 2;
    setTimeout(function(){getRealTimeStream(interval, base_url, query_obj)}, interval*1000);
    sendRequest(url, '', function(req){
        stream = eval('(' + req.responseText + ')');
        if(stream){
            var message = stream.message;
            query_obj.c_time = message.created_at.replace(/[A-Z]|[a-z]/g, ' ');
            var msg_list = [];
            var msg_parent = document.getElementById("msg-list");
            var msgs = msg_parent.getElementsByTagName("div");
            for(var i=0; i < msgs.length; i++){
                if(msgs[i].className == "msg")
                    msg_list.unshift(msgs[i]);
            }
            var first_msg = msgs[0];
            var msg_div = document.createElement("div");
            var anchor = document.createElement("a");
            var name_text = document.createTextNode(message.username);
            var msg_username = document.createElement("span");
            var msg_content = document.createElement("span");
            var msg_text = document.createTextNode(message.body);
            msg_div.className = "msg";
            anchor.href = "/" + message.username;
            anchor.appendChild(name_text);
            msg_username.className = "user-name";
            msg_content.className = "msg-content"
            msg_username.appendChild(anchor);
            msg_content.appendChild(msg_text);
            msg_div.appendChild(msg_username);
            msg_div.appendChild(msg_content);
            if(first_msg){
                msg_parent.insertBefore(msg_div, first_msg);
            }else{
                msg_parent.appendChild(msg_div);
            }
        }
    })

}