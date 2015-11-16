# filename: ./conditionals/conditional_test.rb

require 'benchmark'

def if_1
  Benchmark.bm(7) do |x|
    x.report('if <:') do
      x = 2
      1_000_000_000.times do
        puts 'x < 1' if x < 1
      end
    end
  end
end

def unless_1
  Benchmark.bm(7) do |x|
    x.report('unless >:') do
      x = 2
      1_000_000_000.times do
        puts 'x < 1' unless x > 1
      end
    end
  end
end

def if_2
  Benchmark.bm(7) do |x|
    x.report('if !=:') do
      x = 2
      1_000_000_000.times do
        puts 'x != 2' if x != 2
      end
    end
  end
end

def unless_2
  Benchmark.bm(7) do |x|
    x.report('unless ==:') do
      x = 2
      1_000_000_000.times do
        puts 'x == 2' unless x == 2
      end
    end
  end
end

def if_3
  Benchmark.bm(7) do |x|
    x.report('if >:') do
      x = 0
      1_000_000_000.times do
        puts 'x > 1' if x > 1
      end
    end
  end
end

def unless_3
  Benchmark.bm(7) do |x|
    x.report('unless <:') do
      x = 0
      1_000_000_000.times do
        puts 'x > 1' unless x < 1
      end
    end
  end
end

def if_4
  Benchmark.bm(7) do |x|
    x.report('if ==:') do
      x = 1
      1_000_000_000.times do
        puts 'x == 2' if x == 2
      end
    end
  end
end

def unless_4
  Benchmark.bm(7) do |x|
    x.report('unless !=:') do
      x = 1
      1_000_000_000.times do
        puts 'x != 2' unless x != 2
      end
    end
  end
end

220.times do
  send %i(if_1 unless_1 if_2 unless_2 if_3 unless_3 if_4 unless_4).sample
end
