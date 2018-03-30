def start_draw(n, m)
    text = "◯ "
    m.times {|i| text +="#{i+1}　" }
    text += "\n"
    n.times do |i| 
        text += "#{i+1}"
        m.times do |j|
            text += ":slack: "
        end
        text+= "\n"
    end
    text
end

def set_start(n)
    text_array = [0]*n
    flag = [false]*n
    array = []
    random = Random.new(Time.now.sec)
    (n/2).times do |i|
        array.push(random.rand(0...$emoji.length))
    end
    count = 0
    co = 0
    while count < n/2
        num = random.rand(0...n)
        if !flag[num]
            flag[num]=true
            text_array[num] = array[count]
            co+=1
            if co==2
                co=0
                count+=1
            end
        end
    end
    
    text=""
    text_array.each do |na|
        text += "#{na} "
    end
    return text
end
    
    