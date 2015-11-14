# filename: ./loops/loop_test.rb

require 'benchmark'

def while_loop_1
  Benchmark.bm(7) do |x|
    x.report('while <:') do
      i = 0
      i += 1 while i < 1_000_000_000
    end
  end
end

def while_loop_2
  Benchmark.bm(7) do |x|
    x.report('while !=:') do
      i = 0
      i += 1 while i != 1_000_000_000
    end
  end
end

def until_loop_1
  Benchmark.bm(7) do |x|
    x.report('until ==:') do
      i = 0
      i += 1 until i == 1_000_000_000
    end
  end
end

def until_loop_2
  Benchmark.bm(7) do |x|
    x.report('until >:') do
      i = 0
      i += 1 until i > 1_000_000_000
    end
  end
end

200.times do
  send %i(while_loop_1 until_loop_1 while_loop_2 until_loop_2).sample
end
