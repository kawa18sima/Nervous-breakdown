require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'

ENV['TZ'] = 'JST-9' # Timezone

post '/slack/command' do
    text = params['text']
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
    json({
        text: responseText,
        response_type: 'in_channel',
    })
end

get '/' do
  return "Hello World"
end
