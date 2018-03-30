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
