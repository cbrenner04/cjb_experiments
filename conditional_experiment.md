# Conditional experiment

So my [loop experiment](https://github.com/cbrenner04/whatever/blob/master/loop_experiment.md)
helped me optimize a bit.

Below is an experiment with just pure Ruby. You'll notice I wrote this in a way
that doesn't print anything. I didn't want to have to sift through
200,000,000,000 records.

```ruby
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
        puts 'x != 2' unless x == 2
      end
    end
  end
end

200.times do
  send %i(if_1 unless_1 if_2 unless_2).sample
end
```

That resulted in the following.

Conditional | Operator | user | system | total | real
--- | --- | --- | --- | --- | ---
if | != | 45 | 59.7973 | 0.0302 | 59.8276 | 59.8381
if | < | 49 | 54.2090 | 0.03 | 54.2390 | 54.2488
unless | == | 51 | 58.3076 | .0316 | 58.3392 | 58.3506
unless | > | 55 | 54.5772 | 0.0327 | 54.61 | 54.6207

Conditional | user | system | total | real
--- | --- | --- | --- | ---| real
if | 94 | 56.8842 | 0.0302 | 56.9144 | 59.8381
unless | 106 | 56.3721 | 0.0322 | 56.4042 | 56.4153

  | user | system | total | real
--- | --- | --- | --- | ---
Total | 56.6128 | 0.0312 | 56.644 | 56.6546

Again, it's toss up which is the fastest between `if` and `unless` with the `<`
and `>` operators. The difference in times between `if` `!=` and `if` `<` is
10%. The difference in times between `unless` `==` and `unless` `>` is 7%.

Now for some real world tests.

## Test 1

This may not be a very succinct example but it is one that is one of the greatest
time sucks in my test suite.

```ruby
require 'benchmark'

def choose_rating(element_id, value)
  find("##{element_id} select").find(:xpath, "option[#{(value + 1)}]").select_option
end

def accept_social
  page.driver.execute_script('window.confirm = function() {return true}')
  click_on 'Next'
end

describe 'Active participant in group 1 signs in, navigates to DO tool,', type: :feature do
  before do
    visit "#{ENV['Base_URL']}/participants/sign_in"
    within('#new_participant') do
      fill_in 'participant_email', with: ENV['Participant_Email']
      fill_in 'participant_password', with: ENV['Participant_Password']
    end
    click_on 'Sign in'
    expect(page).to have_content 'HOME'
    visit "#{ENV['Base_URL']}/navigator/contexts/DO"
    click_on 'Add a New Activity'
    find('#new_activity_radio')
    page.execute_script('window.scrollBy(0,500)')
    find('#new_activity_radio').click
    fill_in 'activity_activity_type_new_title', with: 'new planned activity'
  end

  20.times do
    it 'completes Plan a New Activity' do
      Benchmark.bm(7) do |x|
        x.report('unless has_no_css:') do
          page.execute_script('window.scrollBy(0,500)')
          find('.fa.fa-calendar').click
          tomorrow = Date.today + 1
          within('#ui-datepicker-div') do
            unless page.has_no_css?('.ui-datepicker-unselectable.ui-state-disabled', text: "#{tomorrow.strftime('%-e')}")
              find('.ui-datepicker-next.ui-corner-all').click
            end
            click_on tomorrow.strftime('%-e')
          end
          choose_rating('pleasure_0', 4)
          choose_rating('accomplishment_0', 3)
          accept_social
          expect(page).to have_content 'Activity saved'
        end
      end
    end

    it 'completes Plan a New Activity' do
      Benchmark.bm(7) do |x|
        x.report('if has_css:') do
          page.execute_script('window.scrollBy(0,500)')
          find('.fa.fa-calendar').click
          tomorrow = Date.today + 1
          within('#ui-datepicker-div') do
            if page.has_css?('.ui-datepicker-unselectable.ui-state-disabled', text: "#{tomorrow.strftime('%-e')}")
              find('.ui-datepicker-next.ui-corner-all').click
            end
            click_on tomorrow.strftime('%-e')
          end
          choose_rating('pleasure_0', 4)
          choose_rating('accomplishment_0', 3)
          accept_social
          expect(page).to have_content 'Activity saved'
        end
      end
    end
  end
end
```

## Test 2

This example is much more succinct.

```ruby
require 'benchmark'

describe 'Participant signs in', type: :feature do
  before do
    visit "#{ENV['Base_URL']}/participants/sign_in"
    within('#new_participant') do
      fill_in 'participant_email', with: ENV['Participant_Email']
      fill_in 'participant_password', with: ENV['Participant_Password']
    end
    click_on 'Sign in'
    find('h1', text: 'HOME')
    visit "#{ENV['Base_URL']}/social_networking/profile_page"
  end

  20.times do
    it 'visits their profile page' do
      Benchmark.bm(7) do |x|
        x.report('if has_css:') do
          if page.has_css?('.modal-content')
            within('.modal-content') do
              page.all('img')[2].click
            end
          end
          expect(page).to have_content 'Group 1 profile question'
        end
      end
    end

    it 'visits their profile page' do
      Benchmark.bm(7) do |x|
        x.report('unless has_no_css:') do
          unless page.has_no_css?('.modal-content')
            within('.modal-content') do
              page.all('img')[2].click
            end
          end
          expect(page).to have_content 'Group 1 profile question'
        end
      end
    end
  end
end
```

## Test 3

For the third test I wanted to flip it on it's head and see what the
differences are. This test uses `if` `has_no` and `unless` `has`.

```ruby

require 'benchmark'

describe 'Content author visits Content Modules tool', type: :feature do
  before do
    sign_in_user(ENV['Content_Author_Email'], "#{moderator}",
                 ENV['Content_Author_Password'])
    visit "#{ENV['Base_URL']}/think_feel_do_dashboard/arms"
    click_on 'Arm 1'
    click_on 'Manage Content'
    click_on 'Content Modules'
    find('h1', text: 'Listing Content Modules')
  end

  20.times do
    it 'visits a content module' do
      Benchmark.bm(7) do |x|
        x.report('unless has_css:') do
          unless page.has_css?('a', text: 'Home Introduction')
            page.execute_script('window.scrollTo(0,5000)')
            within('.pagination') do
              click_on '2'
            end
          end
          click_on 'Home Introduction'
          expect(page).to have_content 'Tool: LEARN'
        end
      end
    end

    it 'visits a content module' do
      Benchmark.bm(7) do |x|
        x.report('if has_no_css:') do
          if page.has_no_css?('a', text: 'Home Introduction')
            page.execute_script('window.scrollTo(0,5000)')
            within('.pagination') do
              click_on '2'
            end
          end
          click_on 'Home Introduction'
          expect(page).to have_content 'Tool: LEARN'
        end
      end
    end
  end
end
```

## The results:

### Test 1

Conditional | Qualifier | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | has_css | 20 | 0.484 | 0.095 | 0.579 | 6.9119
unless | has_no_css | 20 | 0.0355 | 0.004 | 0.0395 | 1.9963
total |  | 40 | 0.2598 | 0.0495 | 0.3092 | 4.4541

### Test 2

Conditional | Qualifier | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | has_css | 20 | 0.2065 | 0.04 | 0.2465 | 5.3238
unless | has_no_css | 20 | 0.005 | 0 | 0.005 | 0.2799
total |  | 40 | 0.1058 | 0.02 | 0.1258 | 2.8019

### Test 3

Conditional | Qualifier | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | has_no_css | 20 | 0.535 | 0.101 | 0.636 | 5.8401
unless | has_css | 20 | 0.0325 | 0.007 | 0.0395 | 0.8317
total |  | 40 | 0.2838 | 0.054 | 0.3378 | 3.2716

The differences in `total` times are 174%, 192%, and 177%, respectively. The
increases in `total` times, from `unless` to `if`, are 1466%, 4930%, and 1610%,
respectively. The differences in `real` times are 110%, 180%, and 150%. The
increases in `real` times are 346%, 1902%, and 702%.

## Conclusion

Even though it is not conventional to write `unless has_no` due to it being
a double negative, it seems that it is the fastest option for the first two
example. It also seems like using `unless` is faster than `if`. Once again,
going against convention optimizes my test a bit. 
