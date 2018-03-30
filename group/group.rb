def create_team(team)
    response = HTTP.post("https://slack.com/api/conversations.create", params: {token: USERTOKEN, name: team})
    resposeObj = JSON.parse(response.body)
    puts ''
    p resposeObj
    puts ''
end
