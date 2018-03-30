require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require './local.rb'

require 'active_record'
require 'mysql2'


ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class User < ActiveRecord::Base
end

class Team < ActiveRecord::Base
end

ENV['TZ'] = 'JST-9' # Timezone

response = HTTP.get("https://slack.com/api/rtm.connect", params: {token: TOKEN})
resposeObj = JSON.parse(response.body)

url = resposeObj['url']

EM.run do
  puts "Connecting to #{url}..."
  ws = Faye::WebSocket::Client.new(url)

  ws.on :open do |event|
    p [:open]
  end

  ws.on :message do |event|
    msg = JSON.parse(event.data)
    p [:message, JSON.parse(event.data)]
    
    if msg["type"] != 'message'
        next
    end
    text = msg["text"]

    if text =~ /何時/
        now = Time.now
        responseText = "今は#{now.hour}時#{now.min}分#{now.sec}秒です。"
    elsif text =~ /今日/
        today = Time.now
        responseText = "今日は#{today.year}年#{today.month}月#{today.day}日です。"
    elsif text =~ /明日/
        tomorrow = Time.now + (60*60*24)
        responseText = "明日は#{tomorrow.year}年#{tomorrow.month}月#{tomorrow.day}日です。"
    else
        responseText = "例: 何時 / 今日 / 明日"
    end
    
    reply = {
        type: 'message',
        text: responseText,
        channel: msg['channel'],
    }
    puts "Replying: #{reply}"
    ws.send(reply.to_json)
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
    EM.stop
  end

end
