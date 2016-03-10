# filename: ./conditionals/comparing_ordered_tasks_list.rb

# You will not be able to run this from here

# This is implemented here: https://github.com/cbrenner04/conemo_dashboard_features/blob/master/spec/features/nurse/your_patients_spec.rb

feature 'Nurse dashboard' do
  scenario 'Nurse sees participants ordered correctly' do
    expect(page).to be_ordered_correctly
  end
end

def ordered_correctly?
  actual_results = (0..8).map { |i| all('tr')[i].text }
  expected_results = []
  conditionals = [expected_results_1, expected_results_2, expected_results_3]
  conditionals.each { |i| expected_results.concat i }

  expect(actual_results).to eq(expected_results)
end

def expected_results_1
  @expected_results_1 ||= if all('tr')[1].has_text? 'Initial'
                            ['706 Confirmation call',
                             '707 Initial in person appointment',
                             '708 Follow up call week one',
                             '709 Follow up call week three']
                          else
                            ['706 Confirmation call',
                             '708 Follow up call week one',
                             '707 Initial in person appointment',
                             '709 Follow up call week three']
                          end
end

def expected_results_2
  @expected_results_2 ||= if all('tr')[3].has_text? 'Call'
                            ['800 Call to schedule final appointment',
                             '801 Final in person appointment']
                          else
                            ['801 Final in person appointment',
                             '800 Call to schedule final appointment']
                          end
end

def expected_results_3
  @expected_results_3 ||= if last_rows_1
                            ['802 Help request',
                             '803 Lack of connectivity call',
                             '804 Non adherence call']
                          elsif last_rows_2
                            ['802 Help request', '804 Non adherence call',
                             '803 Lack of connectivity call']
                          elsif last_rows_3
                            ['803 Lack of connectivity call',
                             '804 Non adherence call', '802 Help request']
                          elsif last_rows_4
                            ['803 Lack of connectivity call',
                             '802 Help request', '804 Non adherence call']
                          elsif last_rows_5
                            ['804 Non adherence call', '802 Help request',
                             '803 Lack of connectivity call']
                          else
                            ['804 Non adherence call',
                             '803 Lack of connectivity call',
                             '802 Help request']
                          end
end

def last_rows_1
  @last_rows_1 ||= all('tr')[6].has_text?('Help') &&
                   all('tr')[7].has_text?('Lack')
end

def last_rows_2
  @last_rows_2 ||= all('tr')[6].has_text?('Help') &&
                   all('tr')[7].has_text?('Non')
end

def last_rows_3
  @last_rows_3 ||= all('tr')[6].has_text?('Lack') &&
                   all('tr')[7].has_text?('Non')
end

def last_rows_4
  @last_rows_4 ||= all('tr')[6].has_text?('Lack') &&
                   all('tr')[7].has_text?('Help')
end

def last_rows_5
  @last_rows_5 ||= all('tr')[6].has_text?('Non') &&
                   all('tr')[7].has_text?('Help')
end