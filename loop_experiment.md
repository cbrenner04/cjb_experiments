# Loop Experiment

Running this:

```ruby
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
```

resulted in this:

Loop | Operator | # of runs | Average time (in seconds)
--- | --- | --- | ---
while | < | 49 | 18.332206
while | != | 56 | 21.137298
until | > | 53 | 18.330962
until | == | 42 | 19.811054

As you can see, the fastest is a toss up between a `while` loop using the `<`
operator and an `until` loop using the `>` operator. The biggest difference
in these times are between the `while` loop using th `<` operator and the
`while` loop using the `!=` operator, at a 15.3% increase in time. There is
only an 8.07% increase from `until` `>` to `until` `==`.

## Why is this important?

Well I noticed that depending on the type of loop and/or operator I used in my
tests, they would run faster or slower. So I first wanted to test the
differences solely in the loops and operators. There is not a whole lot of
difference between 0.0000000183 seconds per loop at its fastest and 
0.0000000211 seconds per loop at its slowest. Granted these are very simple
loops.

## What's next?

Now I want to test the run time differences for tests using these
loops/operators. You may want to check out my set test set up 
[here](https://github.com/cbrenner04/tfd_core_features/blob/master/spec/spec_helper.rb)
So, running this:

 ```ruby
describe 'A participant signs in', type: :feature do
  before do
    visit "#{ENV['Base_URL']}/participants/sign_in"
    within('#new_participant') do
      fill_in 'participant_email', with: ENV['Participant_Email']
      fill_in 'participant_password', with: ENV['Participant_Password']
    end
    click_on 'Sign in'
    find('h1', text: 'HOME')
  end

  20.times do
    it 'finds a feed item using method 1' do
      start = Time.now
      find('#feed-btn').click
      counter = 0
      while page.has_no_css?('.list-group-item.ng-scope', text: 'nudged participant1') && counter < 15
        page.execute_script('window.scrollTo(0,100000)')
        counter += 1
        puts counter
      end
      expect(page).to have_content 'nudged participant1'
      finish = Time.now
      puts "method 1 #{finish - start}"
    end

    it 'finds a feed item using method 2' do
      start = Time.now
      find('#feed-btn').click
      counter = 0
      while page.has_no_css?('.list-group-item.ng-scope', text: 'nudged participant1') && counter != 15
        page.execute_script('window.scrollTo(0,100000)')
        counter += 1
        puts counter
      end
      expect(page).to have_content 'nudged participant1'
      finish = Time.now
      puts "method 2 #{finish - start}"
    end

    it 'finds a feed item using method 3' do
      start = Time.now
      find('#feed-btn').click
      counter = 0
      until page.has_css?('.list-group-item.ng-scope', text: 'nudged participant1') || counter > 15
        page.execute_script('window.scrollTo(0,100000)')
        counter += 1
        puts counter
      end
      expect(page).to have_content 'nudged participant1'
      finish = Time.now
      puts "method 3 #{finish - start}"
    end

    it 'finds a feed item using method 4' do
      start = Time.now
      find('#feed-btn').click
      counter = 0
      until page.has_css?('.list-group-item.ng-scope', text: 'nudged participant1') || counter == 15
        page.execute_script('window.scrollTo(0,100000)')
        counter += 1
      end
      expect(page).to have_content 'nudged participant1'
      finish = Time.now
      puts "method 4 #{finish - start}"
      puts counter
    end
  end
end
```
results in this:

Loop | Operator | # of runs | Average time (in seconds)
--- | --- | --- | ---
while | < | 20 | 24.571144
while | != | 20 | 24.481480
until | > | 20 | 68.414783
until | == | 20 | 68.807733

## Results

Each loop needed to run 11 times before the example was complete. With the
simple loops, `while` `<` was the fastest and `while` `!=` was the slowest,
however, in the test suite both `while` loops are by far the fastest. The
difference between the `while` loops and the `until` loops are 279.46%. That is
considerable. Interesting that the slowest method in raw ruby is the fastest in
this test example.

I struggled to find a way to run these examples at random. Given the
differences in time to complete, I am not sure that would have much effect.

If you looked at the spec_helper.rb in my test suite you will see that the
`config.default_wait_time = 5`. If you multiply those five seconds by the
number of loops you will get 55 seconds. Clearly none of these methods wait for
the default time for each loop. 

## Conclusions

Using a loop that needs to evaluate to `true` to discontinue is slower than
using a loop that needs to evaluate to `false` to discontinue, at least while
using Capybara with RSpec and Selenium WebDriver. Also, the operator seems to
have little effect in practice and the type of loop has the most effect.

The biggest question for me is: Why? I don't care if I have to write code
unconventionally to get things to go faster (as far as I understand it is
unconventional to write a while loop with a negative).
