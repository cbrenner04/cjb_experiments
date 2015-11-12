# Loop Experiment

Running this:

```ruby
require 'benchmark'

def while_loop_1
  Benchmark.bm(7) do |x|
    x.report('while <:') do
      i = 0
      i += 1 while i < 1000000000
    end
  end
end

def while_loop_2
  Benchmark.bm(7) do |x|
    x.report('while !=:') do
      i = 0
      i += 1 while i != 1000000000
    end
  end
end

def until_loop_1
  Benchmark.bm(7) do |x|
    x.report('until ==:') do
      i = 0
      i += 1 until i == 1000000000
    end
  end
end

def until_loop_2
  Benchmark.bm(7) do |x|
    x.report('until >:') do
      i = 0
      i += 1 until i > 1000000000
    end
  end
end

200.times do
  send %i(while_loop_1 until_loop_1 while_loop_2 until_loop_2).sample
end
```

resulted in this (times are averaged over all runs):

Loop | Operator | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
while | < | 45 | 19.4171 | 0.0211 | 19.4382 | 19.4448
while | != | 48 | 22.3795 | 0.0208 | 22.4004 | 22.4075
until | > | 54 | 19.2931 | 0.0176  | 19.3107 | 19.3181
until | == | 53 | 21.42 | 0.0213 | 21.4413 | 21.4495

Totals by loop

Loop | # of runs | user | system | total | real
--- | --- | --- | --- | --- | ---
while | 93 | 20.9461 | 0.02097 | 20.9671 | 20.9740
until | 107 | 20.3466 | 0.0194 | 20.3661 | 20.3739

Overall totals

user | system | total | real
--- | --- | --- | ---
20.6254 | 0.0202 | 20.6456 | 20.6529

As you can see, the fastest is a toss up between a `while` loop using the `<`
operator and an `until` loop using the `>` operator. The biggest difference
in these times are between the `while` loop using the `<` operator and the
`while` loop using the `!=` operator, at a 15% increase in time. There is
an 11% increase from `until` `>` to `until` `==`.

## Why is this important?

Well I noticed that depending on the type of loop and/or operator I used in my
tests, they would run faster or slower. So I first wanted to test the
differences solely in the loops and operators. There is not a whole lot of
difference between 0.00000001931 seconds per loop at its fastest and 
0.00000002240 seconds per loop at its slowest. Granted these are very simple
loops.

## What's next?

Now I want to test the run time differences for tests using these
loops/operators. You may want to check out my test set up 
[here](https://github.com/cbrenner04/tfd_core_features/blob/master/spec/spec_helper.rb).
So, running this:

 ```ruby
require 'benchmark'

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
      Benchmark.bm(7) do |x|
        x.report('while <:') do
          find('#feed-btn').click
          counter = 0
          while page.has_no_css?('.list-group-item.ng-scope', text: 'nudged participant1') && counter < 15
            page.execute_script('window.scrollTo(0,100000)')
            counter += 1
          end
          expect(page).to have_content 'nudged participant1'
        end
      end
    end

    it 'finds a feed item using method 2' do
      Benchmark.bm(7) do |x|
        x.report('while !=:') do
          find('#feed-btn').click
          counter = 0
          while page.has_no_css?('.list-group-item.ng-scope', text: 'nudged participant1') && counter != 15
            page.execute_script('window.scrollTo(0,100000)')
            counter += 1
          end
          expect(page).to have_content 'nudged participant1'
        end
      end
    end

    it 'finds a feed item using method 3' do
      Benchmark.bm(7) do |x|
        x.report('until >:') do
          find('#feed-btn').click
          counter = 0
          until page.has_css?('.list-group-item.ng-scope', text: 'nudged participant1') || counter > 15
            page.execute_script('window.scrollTo(0,100000)')
            counter += 1
          end
          expect(page).to have_content 'nudged participant1'
        end
      end
    end

    it 'finds a feed item using method 4' do
      Benchmark.bm(7) do |x|
        x.report('until ==:') do
          find('#feed-btn').click
          counter = 0
          until page.has_css?('.list-group-item.ng-scope', text: 'nudged participant1') || counter == 15
            page.execute_script('window.scrollTo(0,100000)')
            counter += 1
          end
          expect(page).to have_content 'nudged participant1'
        end
      end
    end
  end
end
```
results in this (again, times are averaged over all runs):

Loop | Operator | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
while | < | 20 | 0.4355 | 0.0745 | 0.51 | 24.3351
while | != | 20 | 0.437 | 0.075 | 0.512 | 24.1229
until | > | 20 | 1.496 | 0.2555 | 1.7515 | 68.7891
until | == | 20 | 1.4805 | 0.2525 | 1.733 | 68.6116

Loop | # of runs | user | system | total | real
--- | --- | --- | --- | --- | ---
while | 40 | 0.4363 | 0.0748 | 0.511 | 24.4840
until | 40 | 1.4883 | 0.254 | 1.7423 | 68.7003

 | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
total | 80 | 0.9623 | 0.1644 | 1.1266 | 46.4922

## Results

Each loop needed to run 11 times before the example was complete. With the
simple loops, `while` `<` was the fastest and `while` `!=` was the slowest,
however, in the test suite both `while` loops are by far the fastest. The
difference between the `while` loops and the `until` loops is 241% for `total`
and 181% for `real`. That is considerable. 

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
unconventional to write a while loop with a negative), but why is this the case?
