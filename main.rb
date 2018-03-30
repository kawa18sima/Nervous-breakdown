require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require './local.rb'
require './game/view.rb'
require './game/emoji.rb'

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
$start_flag = false
$id = 1

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

    if text =~ /start/ && !$start_flag
        n,m = 4,5
        $start_flag = true
        responseText = start_draw(n, m)
        team = Team.find($id)
        team.borad = set_start(n*m)
        team.save
    elsif  text == "使い方"
        responseText = <<-EOS
縦の数字　横の数字　の順で２マス指定してください
例
11 23
EOS
        
    end
    
    reply = {
        type: 'message',
        text: responseText,
        channel: msg['channel'],
    }
    puts "Replying: #{reply}"
    tab = ws.send(reply.to_json)
    puts 
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
    EM.stop
  end

end
