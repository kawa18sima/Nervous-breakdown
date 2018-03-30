def create_team(team)
    response = HTTP.post("https://slack.com/api/conversations.create", params: {token: USERTOKEN, name: team})
    resposeObj = JSON.parse(response.body)
    puts ''
    p resposeObj
    puts ''
end

def getplayerlist(*)
    userlist = ["members"]
    uri = URI("https://slack.com/api/users.list?token="+USERTOKEN)
    req = Net::HTTP::Get.new(uri)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }
    array =[]
    if res.is_a?(Net::HTTPSuccess)
        result = JSON.parse(res.body)
        
        p result
        result["members"].each do |user|
             array.push(user['id'])
        end
        p array
    else
        abort "get access_token failed: body=" + res.body
    end
    array.each do |user|
        user_list = User.where(name: user).first_or_create
    end
end

def team_allocation(*)
    users = User.all
    n = users.count
    team_max = n / 3 + [n % 3,1].min
    team_max.times do |i|
        num = i + 1
        team = Team.where(id: num).first_or_initialize
        # team = Team.new()
        team.people = 0
        team.save
    end
    random = Random.new(Time.now.sec)
    users.each do |user|
        while true
            rand_num = random.rand(1..team_max)
            team = Team.find(rand_num)
            if team.people < 3
                team.people += 1
                user.team_id = rand_num
                team.borad = set_start(20)
                team.save
                user.save
                break
            end
        end
    end
end
