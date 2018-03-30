require 'http'
require 'net/http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require './local.rb'
require './game/view.rb'
require './game/emoji.rb'
require './game/message.rb'
require './game/fin.rb'
require './group/group.rb'

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
    team = Team.find($id)
    n,m = 4,5
    if text =~ /start/ && !$start_flag
        # create_team('game1')
        getplayerlist()
        team_allocation()
        $start_flag = true
        
        responseText = start_draw(n, m)
        team.ts = post_message(responseText,msg['channel'])
        team.save
        responseText= ''
    elsif  text == "使い方"
        responseText = <<-EOS
縦の数字　横の数字　の順で２マス指定してください
例
11 23
EOS
    elsif $start_flag && text != nil && text.length ==5
        array = text.split(' ').map{|index| index.to_i}
        numbers=[]
        array.each do |num|
            numbers.push((num/10-1)*m + num%10 -1)
        end
        bord = team.borad
        bord = bord.split(' ').map{|index| index.to_i}
        up_text=update_view(n,m,numbers,bord)
        update_message(up_text,msg['channel'],team.ts)
        sleep(3)
        up_text=equivalence_evaluation(n,m,numbers,bord)
        update_message(up_text,msg['channel'],team.ts)
        delete_message(msg['ts'],msg['channel'])
    end
    team = Team.find($id)
    if finish_game(team.borad, n*m) && $start_flag
        $start_flag = false
        responseText = 'ゲーム終了'
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
