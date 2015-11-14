# Loop Experiment

Running this:

```ruby
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
```

resulted in this (times are averaged over all runs):

Loop | Operator | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
while | < | 45 | 19.4171 (18.62 - 20.08, 7.55%) | 0.0211 (0.00 - 0.06, 200%) | 19.4382 (18.64 - 20.06, 7.34%) | 19.4448 (18.6493 - 20.1261, 7.62%)
while | != | 48 | 22.3795 (21.70 - 23.36, 7.37%) | 0.0208 (0.01 - 0.05, 133.33%) | 22.4004 (21.71 - 23.41, 7.54%) | 22.4075 (21.7208 - 23.4173, 7.52%)
until | > | 54 | 19.2931 (18.54 - 19.98, 7.48%) | 0.0176 (0.00 - 0.03, 200%) | 19.3107 (18.55 - 20.00, 7.52%) | 19.3181 (18.5506 - 20.0207, 7.62%)
until | == | 53 | 21.42 (20.28 - 22.38, 9.85%) | 0.0213 (0.01 - 0.07), 150% | 21.4413 (20.50 - 22.45, 9.08%) | 21.4495 (20.5036 - 22.5006, 9.29%)

Totals by loop

Loop | # of runs | user | system | total | real
--- | --- | --- | --- | --- | ---
while | 93 | 20.9461 (18.62 - 23.36, 22.58%) | 0.02097 (0.00 - 0.06, 200%) | 20.9671 (18.64 - 23.41, 22.69%) | 20.9740 (18.6493 - 23.4173, 22.69%)
until | 107 | 20.3466 (18.54 - 22.38, 18.77%) | 0.0194 (0.00 - 0.07, 200%) | 20.3661 (18.55 - 22.45, 19.02%) | 20.3739 (18.5506 - 22.500, 19.24%)

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
while | < | 20 | 0.4355 (0.39 - 0.47, 18.60%) | 0.0745 (0.06 - 0.09, 40%) | 0.51 (0.45 - 0.56, 21.78%) | 24.3351 (22.2481 - 25.5645, 13.87%)
while | != | 20 | 0.437 (0.42 - 0.45, 6.90%) | 0.075 (0.07 - 0.08, 13.33%) | 0.512 (0.49 - 0.53, 7.84%) | 24.1229 (23.1539 - 25.8288, 10.92%)
until | > | 20 | 1.496 (1.44 - 1.55. 7.36%) | 0.2555 (0.25 - 0.27, 7.69%) | 1.7515 (1.69 - 1.81, 6.86%) | 68.7891 (66.9843 - 71.065, 5.91%)
until | == | 20 | 1.4805 (1.41 - 1.52, 7.51%) | 0.2525 (0.24 - 0.27, 11.76%) | 1.733 (1.65 - 1.79, 8.14%) | 68.6116 (65.447 - 71.498, 8.84%)

Loop | # of runs | user | system | total | real
--- | --- | --- | --- | --- | ---
while | 40 | 0.4363 (0.39 - 0.74, 18.60%) | 0.0748 (0.06 - 0.09, 40%) | 0.511 (0.45 - 0.56, 21.78%) | 24.4840 (22.2481 - 25.5645, 14.90%)
until | 40 | 1.4883 (1.41, 1.55, 9.46%) | 0.254 (0.24 - 0.27, 11.76%) | 1.7423 (1.65 - 1.81, 9.25%) | 68.7003 (65.447 - 71.498, 8.84%)

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
