def while_loop_1
  start = Time.now
  i = 0
  i += 1 while i < 1000000000
  finish = Time.now
  puts "while_1 #{finish - start}"
end

def while_loop_2
  start = Time.now
  i = 0
  i += 1 while i != 1000000000
  finish = Time.now
  puts "while_2 #{finish - start}"
end

def until_loop_1
  start = Time.now
  i = 0
  i += 1 until i == 1000000000
  finish = Time.now
  puts "until_1 #{finish - start}"
end

def until_loop_2
  start = Time.now
  i = 0
  i += 1 until i > 1000000000
  finish = Time.now
  puts "until_2 #{finish - start}"
end

200.times do
  send %i(while_loop_1 until_loop_1 while_loop_2 until_loop_2).sample
end
