# Conditional experiment

So my [loop experiment](https://github.com/cbrenner04/whatever/blob/master/loop_experiment.md)
helped me optimize a bit. I could use some help with writing some raw Ruby with
conditionals to test the difference but based on the previous experiment, I
don't think it is worth it. So I'm just gonna get down to the real world
example.

## The Test

```ruby
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
  end

  20.times do
    it 'completes Plan a New Activity' do
      start = Time.now
      click_on 'Add a New Activity'
      find('#new_activity_radio')
      page.execute_script('window.scrollBy(0,500)')
      find('#new_activity_radio').click
      fill_in 'activity_activity_type_new_title', with: 'new planned activity'
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
      finish = Time.now
      puts "1 #{finish - start}"
    end

    it 'completes Plan a New Activity' do
      start = Time.now
      click_on 'Add a New Activity'
      find('#new_activity_radio')
      page.execute_script('window.scrollBy(0,500)')
      find('#new_activity_radio').click
      fill_in 'activity_activity_type_new_title', with: 'new planned activity'
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
      finish = Time.now
      puts "2 #{finish - start}"
    end
  end
end
```

## The results:

Conditional | Qualifier | # of runs | Average time (in seconds)
--- | --- | --- | ---
unless | has_no| 20 | 2.8889815
if | hss | 20 | 7.77466095

## Conclusion

Even though it is not conventional to write `unless has_no` due to it being
a double negative, it seems that it is the fastest option for this example.
Once again, going against convention optimizes my test a bit. 

