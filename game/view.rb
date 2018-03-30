def first_row(m)
    text = "◯ "
    m.times {|i| text +="#{i+1}　" }
    text += "\n"
    return text 
end

def start_draw(n, m)
    text = first_row(m)
    n.times do |i| 
        text += "#{i+1}"
        m.times do |j|
            text += ":slack: "
        end
        text+= "\n"
    end
    return text
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

def update_view(n,m,numbers,bord)
    text = first_row(m)
    n.times do |i| 
        text += "#{i+1}"
        m.times do |j|
            if bord[i*m+j]<0
                text +="       "
            elsif numbers[0] == i*m+j || numbers[1] == i*m+j
                text += "#{$emoji[bord[i*m+j]]} "
            else
                text += ":slack: "
            end
        end
        text+= "\n"
    end
    return text
end

def equivalence_evaluation(n,m,numbers,bord)
    text = first_row(m)
    bord[numbers[0]] = bord[numbers[1]] = -1 if bord[numbers[0]] == bord[numbers[1]]
    n.times do |i| 
        text += "#{i+1}"
        m.times do |j|
            if bord[i*m+j]<0
                text +="       "
            else
                text += ":slack: "
            end
        end
        text+= "\n"
    end
    team = Team.find($id)
    team.borad = text_bord(bord)
    team.save
    return text
end

def text_bord(bords)
    text = ''
    bords.each do |bord|
        text += bord.to_s + ' '
    end
    text
end
