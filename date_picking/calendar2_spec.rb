# filename: ./date_picking/calendar2_spec.rb

# You will not be able to run this from here.

# This is an example of a complex method used in
# https://github.com/cbrenner04/munoz_features/blob/master/spec/features/participants/quit_date_spec.rb
# See ./calendar_spec.rb for my breakdown of this method into separate methods
# based on rubocop complexity rules. The methods in ./calendar_spec.rb have
# been implemented in the above mentioned repo

describe 'Example spec', type: :feature do
  it 'sets a Quit Date' do
    sign_in_pt_en(pt)
    visit 'http://www.your_site.com/sign_in'
    tomorrow = Date.today + 1
    unless page.has_css?('.ng-binding', text: "#{tomorrow.strftime('%b %Y')}")
      find('a', text: 'Next').click
    end

    select_day("#{tomorrow}")
    expect(page).to have_css('.text-right.ng-binding.ng-scope.success',
                             text: "#{tomorrow.strftime('%-d')}")
  end
end

def select_day(date)
  d = Date.parse(date)
  num = d.mday
  wrong_date = first('.text-right.ng-binding.ng-scope', text: "#{num}").text
  if num.between?(1, 9) || num.between?(30, 31) ||
     num >= 23 && page.has_text?("#{num}", count: 2)
    if num == 2
      if page.has_no_text?('29', count: 2)
        if wrong_date.to_i.between?(23, 28)
          wrong_date_reps = { 23 => 6, 24 => 5, 25 => 4, 26 => 3, 27 => 2,
                              28 => 1 }
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[wrong_date_reps[wrong_date.to_i]]
          selection.click
        else
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[0]
          selection.click
        end
      else
        if wrong_date.to_i.between?(23, 29)
          wrong_date_reps = { 23 => 7, 24 => 6, 25 => 5, 26 => 4, 27 => 3,
                              28 => 2, 29 => 1 }
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[wrong_date_reps[wrong_date.to_i]]
          selection.click
        else
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[0]
          selection.click
        end
      end
    elsif num == 3
      last_date = page.all('.text-right.ng-binding.ng-scope', text: "#{num}").last
      last_date_text = last_date.text
      if wrong_date.to_i == 3
        first('.text-right.ng-binding.ng-scope', text: "#{num}").click
      elsif wrong_date.to_i == 30
        if page.has_text?('30', count: 2) && page.has_text?('31', count: 1) &&
           last_date_text.to_i == 31
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[1]
          selection.click
        elsif (page.has_text?('30', count: 2) &&
              page.has_text?('31', count: 1) && last_date_text.to_i != 31) ||
              (page.has_text?('30', count: 2) && page.has_text?('31', count: 2))
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[2]
          selection.click
        end
      elsif wrong_date.to_i == 31
        selection = page.all('.text-right.ng-binding.ng-scope',
                             text: "#{num}")[2]
        selection.click
      elsif wrong_date.to_i == 23
        if page.has_no_text?('30', count: 2) && last_date_text.to_i == 30
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[1]
          selection.click
        elsif (page.has_no_text?('30', count: 2) &&
              last_date_text.to_i != 30) || (page.has_text?('30', count: 2) &&
              page.has_text?('31', count: 1) && wrong_date.to_i == 31)
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[3]
          selection.click
        elsif (page.has_text?('30', count: 2) &&
              page.has_text?('31', count: 1) && wrong_date.to_i != 31) ||
              (page.has_text?('30', count: 2) && page.has_text?('31', count: 2))
          selection = page.all('.text-right.ng-binding.ng-scope',
                               text: "#{num}")[4]
          selection.click
        end
      end
    elsif first('.text-right.ng-binding.ng-scope', text: "#{num}")[:class]
          .include?('text-muted')
      selection = page.all('.text-right.ng-binding.ng-scope',
                           text: "#{num}")[1]
      selection.click
    else
      first('.text-right.ng-binding.ng-scope', text: "#{num}").click
    end
  else
    find('.text-right.ng-binding.ng-scope', text: "#{num}").click
  end
end
