require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'
require 'date'
require 'time'

def clean_zipcode(zipcode)
	# zipcode must not be empty (else 00000), truncate to 5 digits,
	# and have padding 0s if length < 5
	zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
	# validate and format a phone number
	# e.g. 6154385000 => (615) 438-5000; 315.450.6000 => (315) 450-6000
	# strip out any whitespace, -, (, ), and .
	phone.gsub!(/[^\d]/, "")
	# if the phone number is 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
	if phone.length == 11 && phone.start_with?("1")
		phone.slice!(0)
	# if the phone number is 11 digits and the first number is not 1, then it is a bad number
	# if the phone number is more than 11 digits, assume that it is a bad number
	elsif phone.length != 10
		return "invalid"
	end
	# put in the () and -
	phone.insert(0, "(").insert(4, ") ").insert(-5, "-")
end

def hour_from_datetime(datetime)
	# %D is a combination: %D - Date (%m/%d/%y)
	DateTime.strptime(datetime, "%D %H:%M").hour
end

def wday_from_datetime(datetime)
	# %A is the full weekday name, e.g. "Sunday", "Wednesday"
	# Date#wday will return the index of that day, e.g. 0-6
	DateTime.strptime(datetime, "%D").strftime("%A")
end

def legislators_by_zipcode(zipcode)
	civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
	civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

	begin
		legislators = civic_info.representative_info_by_address(
			address: zipcode,
			levels: "country",
			roles: ["legislatorUpperBody", "legislatorLowerBody"]
		).officials
	rescue
		"Invalid address for #{zipcode}"
	end
end

def save_thank_you_letter(id, form_letter)
	Dir.mkdir("output") unless Dir.exist?("output")

	filename = "output/thanks_#{id}.html"

	File.open(filename, "w") do |file|
		file.puts form_letter
	end
end

puts "Event manager initialized!"

template_letter = File.read('form_letter.erb')
erb_template = ERB.new(template_letter)
# Store the frequency of hours and days for each attendee. Hour ranges are 0 - 23
peak_hours = Hash.new(0)
peak_days = Hash.new(0)

contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

contents.each do |row|
	id = row[0]
	name = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])	
	phone = clean_phone(row[:homephone])
	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	save_thank_you_letter(id, form_letter)
	hour = hour_from_datetime(row[:regdate])
	day_of_week = wday_from_datetime(row[:regdate])
	peak_hours[hour] += 1
	peak_days[day_of_week] += 1
end

# Assignments: Time Targeting and Day of the Week Targeting
peak_hour = peak_hours.sort_by { | key, value | value }.reverse.first[0]
peak_wdy = peak_days.sort_by { |key, value | value }.reverse.first[0]
puts "Peak hour is #{peak_hour <= 12 ? peak_hour : peak_hour - 12}:00 #{peak_hour <= 12 ? "AM" : "PM"}"
puts "Peak week day is #{peak_wdy}"