# filename: ./date_picking/calendar_spec.rb

# You will not be able to run this from here.

# This is an example of a breaking down a complex method based on rubocop
# complexity rules. See ./calendar2_spec.rb for original. These methods are
# implemented in
# https://github.com/cbrenner04/munoz_features/blob/master/spec/features/participants/quit_date_spec.rb

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
  if num.between?(1, 9) || num.between?(30, 31) ||
     num >= 23 && page.has_text?("#{num}", count: 2)
    unusual_day(num)
  else
    find('.text-right.ng-binding.ng-scope', text: "#{num}").click
  end
end

# Day is either 1 - 9; 30 or 31; 23 or greater and there are two choices
def unusual_day(num)
  if num == 2
    unusual_day_2(num)
  elsif num == 3
    unusual_day_3(num)
  elsif first('.text-right.ng-binding.ng-scope', text: "#{num}")[:class]
        .include?('text-muted')
    calendar_date(num, 1)
  else
    first('.text-right.ng-binding.ng-scope', text: "#{num}").click
  end
end

# Day is the 2nd
def unusual_day_2(num)
  if page.has_no_text?('29', count: 2)
    february(num)
  else
    not_february(num)
  end
end

# Day is the 3rd
def unusual_day_3(num)
  wrong_date = first('.text-right.ng-binding.ng-scope', text: "#{num}").text
  if wrong_date.to_i == 3
    first('.text-right.ng-binding.ng-scope', text: "#{num}").click
  elsif wrong_date.to_i == 30
    wrong_day_30(num)
  elsif wrong_date.to_i == 31
    calendar_date(num, 2)
  elsif wrong_date.to_i == 23
    unusual_day_4(num)
  end
end

# Day is the 3rd and the first choice is the 30th
def wrong_day_30(num)
  if two_30_one_31_last(num)
    calendar_date(num, 1)
  elsif two_30_one_31_not_last(num) || two_30_two_31
    calendar_date(num, 2)
  end
end

# Day is the 3rd, and it's March
def one_30_last(num)
  date = page.all('.text-right.ng-binding.ng-scope', text: "#{num}").last
  wrong_date = date.text
  page.has_no_text?('30', count: 2) && wrong_date.to_i == 30
end

# Day is the 3rd, and it's January
def one_30_not_last(num)
  date = page.all('.text-right.ng-binding.ng-scope', text: "#{num}").last
  wrong_date = date.text
  page.has_no_text?('30', count: 2) && wrong_date.to_i != 30
end

# Day is the 3rd, first choice is the 30th, second choice is not the 31st
def two_30_one_31_last(num)
  date = page.all('.text-right.ng-binding.ng-scope', text: "#{num}").last
  wrong_date = date.text
  page.has_text?('30', count: 2) && page.has_text?('31', count: 1) &&
    wrong_date.to_i == 31
end

# Day is the 3rd, first choice is the 30th, second choice is the 31st
def two_30_one_31_not_last(num)
  date = page.all('.text-right.ng-binding.ng-scope', text: "#{num}").last
  wrong_date = date.text
  page.has_text?('30', count: 2) && page.has_text?('31', count: 1) &&
    wrong_date.to_i != 31
end

# Day is the 3rd, first choice is the 30th, second choice is the 31st
def two_30_two_31
  page.has_text?('30', count: 2) && page.has_text?('31', count: 2)
end

# Day is the 3rd, first choice is the 23rd
def unusual_day_4(num)
  if one_30_last(num)
    calendar_date(num, 1)
  elsif one_30_not_last(num) || two_30_one_31_last(num)
    calendar_date(num, 3)
  elsif two_30_one_31_not_last(num) || two_30_two_31
    calendar_date(num, 4)
  end
end

# Day is the 2nd, the previous month is February on a non-leap year
def february(num)
  wrong_date = first('.text-right.ng-binding.ng-scope', text: "#{num}").text
  if wrong_date.to_i.between?(23, 28)
    wrong_date_replacements = { 23 => 6, 24 => 5, 25 => 4, 26 => 3,
                                27 => 2, 28 => 1 }
    calendar_date(num, wrong_date_replacements[wrong_date.to_i])
  else
    calendar_date(num, 0)
  end
end

# Day is the 2nd, and the month and the previous month is not February
# OR Day is the 2nd, and any month in a leap year
def not_february(num)
  wrong_date = first('.text-right.ng-binding.ng-scope', text: "#{num}").text
  if wrong_date.to_i.between?(23, 29)
    wrong_date_replacements = { 23 => 7, 24 => 6, 25 => 5, 26 => 4, 27 => 3,
                                28 => 2, 29 => 1 }
    calendar_date(num, wrong_date_replacements[wrong_date.to_i])
  else
    calendar_date(num, 0)
  end
end

def calendar_date(num, y)
  selection = page.all('.text-right.ng-binding.ng-scope', text: "#{num}")[y]
  selection.click
end
