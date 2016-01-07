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
  if num.between?(1, 9)
    day_less_than_10(num)
  elsif num.between?(30, 31) ||
        num >= 23 && page.has_text?("#{num}", count: 2)
    day_greater_than_23
  else
    find('.text-right.ng-binding.ng-scope', text: "#{num}").click
  end
end

# Find the first day with today's date's number
def first_day(num)
  first('.text-right.ng-binding.ng-scope', text: "#{num}")
end

# Day is either 1 - 9
def day_less_than_10(num)
  if num == 1
    unusual_day_1(num)
  elsif num == 2
    unusual_day_2(num)
  elsif num == 3
    unusual_day_3(num)
  elsif num.between?(4, 9) && page.has_text?("2#{num}", count: 2)
    calendar_date(num, 1)
  else
    first_day(num).click
  end
end

# Day is 23 or greater
def day_greater_than_23(num)
  if num >= 23 && page.has_text?("#{num}", count: 2)
    calendar_date(num, 1)
  else
    first_day(num).click
  end
end

# Get the text for the first date with today's date's number
def wrong_date(num)
  first_day(num).text
end

# Day is the 1st
def unusual_day_1(num)
  if wrong_date(num).to_i == 1
    first_day(num).click
  elsif wrong_date(num).to_i == 31
    calendar_date(num, 1)
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
  if wrong_date(num).to_i == 3
    first_day(num).click
  elsif wrong_date(num).to_i == 30
    wrong_day_30(num)
  elsif wrong_date(num).to_i == 31
    calendar_date(num, 1)
  elsif wrong_date(num).to_i == 23
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

# Find the last day with today's date's number
def last_date_text(num)
  last_date = page.all('.text-right.ng-binding.ng-scope', text: "#{num}").last
  last_date.text
end

# Day is the 3rd, and it's March
def one_30_last(num)
  page.has_no_text?('30', count: 2) && last_date_text(num).to_i == 30
end

# Day is the 3rd, and it's January
def one_30_not_last(num)
  page.has_no_text?('30', count: 2) && last_date_text(num).to_i != 30
end

# Day is the 3rd, first choice is the 30th, second choice is not the 31st
def two_30_one_31_last(num)
  page.has_text?('30', count: 2) && page.has_text?('31', count: 1) &&
    last_date_text(num).to_i == 31
end

# Day is the 3rd, first choice is the 30th, second choice is the 31st
def two_30_one_31_not_last(num)
  page.has_text?('30', count: 2) && page.has_text?('31', count: 1) &&
    last_date_text(num).to_i != 31
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
    calendar_date(num, 2)
  elsif two_30_one_31_not_last(num) || two_30_two_31
    calendar_date(num, 3)
  end
end

# Day is the 2nd, the previous month is February on a non-leap year
def february(num)
  if wrong_date(num).to_i.between?(23, 28)
    wrong_date_replacements = { 23 => 6, 24 => 5, 25 => 4, 26 => 3,
                                27 => 2, 28 => 1 }
    calendar_date(num, wrong_date_replacements[wrong_date(num).to_i])
  else
    first_day(num).click
  end
end

# Day is the 2nd, and the month and the previous month is not February
# OR Day is the 2nd, and any month in a leap year
def not_february(num)
  if wrong_date(num).to_i.between?(23, 29)
    wrong_date_replacements = { 23 => 7, 24 => 6, 25 => 5, 26 => 4, 27 => 3,
                                28 => 2, 29 => 1 }
    calendar_date(num, wrong_date_replacements[wrong_date(num).to_i])
  else
    first_day(num).click
  end
end

# select the date
def calendar_date(num, y)
  selection = page.all('.text-right.ng-binding.ng-scope', text: "#{num}")[y]
  selection.click
end
