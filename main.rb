require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require './local.rb'
require './game/view.rb'

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
responseText = "" 

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

    if text =~ /start/
        n,m = 4,5
        now = Time.now
        responseText = start_draw(n, m)
        #"今は#{now.hour}時#{now.min}分#{now.sec}秒です。"
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
