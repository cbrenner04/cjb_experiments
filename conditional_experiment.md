# Conditional experiment

So my [loop experiment](https://github.com/cbrenner04/whatever/blob/master/loop_experiment.md)
helped me optimize a bit. I could use some help with writing some raw Ruby with
conditionals to test the difference but based on the previous experiment, I
don't think it is worth it. So I'm just gonna get down to the real world
example.

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

## Conclusion

Even though it is not conventional to write `unless has_no` due to it being
a double negative, it seems that it is the fastest option for the first two
example. Once again, going against convention optimizes my test a bit. 
