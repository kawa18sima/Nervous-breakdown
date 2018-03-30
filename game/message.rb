def update_message(text,channel, ts)
    response = HTTP.post("https://slack.com/api/chat.update", params: {token: TOKEN, text: text, channel: channel, ts: ts})
end

def post_message(text,channel)
    response = HTTP.post("https://slack.com/api/chat.postMessage", params: {token: TOKEN,text: text, channel: channel})
    resposeObj = JSON.parse(response.body)
    return resposeObj['ts']
end

def delete_message(ts, channel)
    response = HTTP.post("https://slack.com/api/chat.delete", params: {token: ADTOKEN,channel: channel, ts: ts,as_user: true})
    resposeObj = JSON.parse(response.body)
    p resposeObj
    
end
