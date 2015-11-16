# Conditional experiment

So my [loop experiment](https://github.com/cbrenner04/whatever/blob/master/loops/README.md)
helped me optimize a bit.

Below is an experiment with just pure Ruby. You'll notice I wrote this in a way
that doesn't print anything. I didn't want to have to sift through
200,000,000,000 records. This was set to `400.times` but that was taking way
too long, so I stopped it after 220.

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
```

That resulted in the following.

Conditional | Operator | Count | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | != | 35 | 63.1031 | 0.1077 | 63.2108 | 63.2851
if | < | 29 | 55.6534 | 0.0868 | 55.7403 | 55.7994
if | == | 28 | 55.8571 | 0.08 | 58.9371 | 58.9873
if | > | 28 | 56.0464 | 0.1021 | 56.1485 | 56.2189

Conditional | Operator | Count | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
unless | != | 32 | 63.9856 | 0.1366 | 64.1222 | 64.2372
unless | < | 25 | 57.4412 | 0.1148 | 57.556 | 57.6501
unless | == | 24 | 61.31796 | 0.0983 | 61.4163 | 61.4978
unless | > | 19 | 56.6779 | 0.0821 | 54.76 | 58.8615

Conditional | Count | user | system | total | real
--- | --- | --- | --- | --- | ---
if | 120 | 58.6655 | 0.0949 | 58.7604 | 58.8244
unless | 100 | 60.3208 | 0.1116 | 60.4324 | 60.5231

Operator | Count | user | system | total | real
--- | --- | --- | --- | --- | ---
`!=` | 67 | 63.5246 | 0.1215 | 63.6461 | 63.7398
`<` | 54 | 56.4811 | 0.0998 | 56.5809 | 56.6562
`==` | 52 | 59.9929 | 0.0885 | 60.0814 | 60.1460
`>` | 47 | 56.3017 | 0.09404 | 56.3957 | 56.4605


  | user | system | total | real
--- | --- | --- | --- | ---
Total | 59.4179 | 0.1025 | 59.5204 | 59.5965

It looks like the operator accounts for the most variability but it's mostly a
toss up on what's fastest in the above test.

Now for some real world tests. These tests are paired down tests from this test
[suite](https://github.com/cbrenner04/tfd_core_features). The entirety of the
[participant](https://github.com/cbrenner04/tfd_core_features/tree/master/spec/features/participant)
specs were run first to add data to the database. The database was then dumped
and reloaded. These tests were then added to the repo in separate files and
run.

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

Conditional | Matcher | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | has_css | 20 | 0.484 | 0.095 | 0.579 | 6.9119
unless | has_no_css | 20 | 0.0355 | 0.004 | 0.0395 | 1.9963
total |  | 40 | 0.2598 | 0.0495 | 0.3092 | 4.4541

### Test 2

Conditional | Matcher | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | has_css | 20 | 0.2065 | 0.04 | 0.2465 | 5.3238
unless | has_no_css | 20 | 0.005 | 0 | 0.005 | 0.2799
total |  | 40 | 0.1058 | 0.02 | 0.1258 | 2.8019

### Test 3

Conditional | Matcher | # of runs | user | system | total | real
--- | --- | --- | --- | --- | --- | ---
if | has_no_css | 20 | 0.535 | 0.101 | 0.636 | 5.8401
unless | has_css | 20 | 0.0325 | 0.007 | 0.0395 | 0.8317
total |  | 40 | 0.2838 | 0.054 | 0.3378 | 3.2716

The differences in `total` times are 174%, 192%, and 177%, respectively. The
increases in `total` times, from `unless` to `if`, are 1466%, 4930%, and 1610%,
respectively. The differences in `real` times are 110%, 180%, and 150%. The
increases in `real` times are 346%, 1902%, and 702%.

Even though it is not conventional to write `unless has_no` due to it being
a double negative, it seems that it is the fastest option for the first two
example. It also seems like using `unless` is faster than `if`. Once again,
going against convention optimizes my test a bit. 

But, there is an example that throws a wrench in these theory.

## Test 4

```ruby
require 'benchmark'

describe 'An active participant signs in', type: :feature do
  20.times do
    it 'signs in using unless' do
      Benchmark.bm(7) do |x|
        x.report('unless:') do
          visit "#{ENV['Base_URL']}/participants/sign_in"
          unless page.has_css?('#new_participant') # this should evaluate to false, but is a catch in case last session did not sign out
            within('.navbar-collapse') do
              unless page.has_text?('Sign Out')
                find('a', text: ENV['Participant_Email']).click
              end
              click_on 'Sign Out'
            end
            expect(page).to have_content 'Forgot your password?'
          end
          unless page.has_no_css?('#new_participant')
            within('#new_participant') do
              fill_in 'participant_email', with: ENV['Participant_Email']
              fill_in 'participant_password', with: ENV['Participant_Password']
            end
            click_on 'Sign in'
            expect(page).to have_content 'HOME'
          end
        end
      end
    end

    it 'signs in using if' do
      Benchmark.bm(7) do |x|
        x.report('if:') do
          visit "#{ENV['Base_URL']}/participants/sign_in"
          if page.has_no_css?('#new_participant') # this should evaluate to false, but is a catch in case last session did not sign out
            within('.navbar-collapse') do
              if page.has_no_text?('Sign Out')
                find('a', text: ENV['Participant_Email']).click
              end
              click_on 'Sign Out'
            end
            expect(page).to have_content 'Forgot your password?'
          end
          if page.has_css?('#new_participant')
            within('#new_participant') do
              fill_in 'participant_email', with: ENV['Participant_Email']
              fill_in 'participant_password', with: ENV['Participant_Password']
            end
            click_on 'Sign in'
            expect(page).to have_content 'HOME'
          end
        end
      end
    end

    it 'signs in using convention' do
      Benchmark.bm(7) do |x|
        x.report('convention:') do
          visit "#{ENV['Base_URL']}/participants/sign_in"
          unless page.has_css?('#new_participant') # this should evaluate to false, but is a catch in case last session did not sign out
            within('.navbar-collapse') do
              unless page.has_text?('Sign Out')
                find('a', text: ENV['Participant_Email']).click
              end
              click_on 'Sign Out'
            end
            expect(page).to have_content 'Forgot your password?'
          end
          if page.has_css?('#new_participant')
            within('#new_participant') do
              fill_in 'participant_email', with: ENV['Participant_Email']
              fill_in 'participant_password', with: ENV['Participant_Password']
            end
            click_on 'Sign in'
            expect(page).to have_content 'HOME'
          end
        end
      end
    end
  end
end
```

The above example resulted in:

Conditional | user | system | total | real
--- | --- | --- | --- | ---
unless | 0.1835 | 0.0345 | 0.218 | 8.8436
if | 0.183 | 0.035 | 0.218 | 8.6886
convention | 0.025 | 0.0025 | 0.0275 | 3.7416

As you can see, the difference between `if` and `unless` is negligible, while
mixing the two, and therefore keeping closer to convention, is fastest by far.

## Conclusions?

The first three tests make it seem that using `unless` in favor of `if`, no
matter the matcher, will speed up my tests. However, the fourth test makes me
wonder if there is more to this.
