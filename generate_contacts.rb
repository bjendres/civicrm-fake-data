#!/usr/bin/ruby
# encoding: utf-8

=begin	license
This script generates Fake data for import into CiviCRM

Copyright (C) 2013  SYSTOPIA Organisationsberatung - www.systopia.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

In accordance with Section 7(b) of the GNU Affero General Public License, 
a covered work must retain the above copyright notice as an attribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end	license


require 'rubygems'
require 'faker'
require 'set'
require 'securerandom'
require 'date'

STDOUT.sync = true
Faker::Config.locale = :de
$country = "Deutschland"

$now = DateTime.now
$emails = Set.new []
$members = []
$contributors = []
$source = "Fakedaten_" + $now.strftime('%Y-%m-%d')

$max_entries_per_file = 2000				# files will be rotated when max-entries are reached

$contact_count = 1200						# number of contacts to generate
$organization_count = 300					# number of organizations to generate. every organization gets an extra contact
$contribution_member = 0.03					# 3% of contacts will be members
$contribution_small = 0.20					# 20% of members will give small amounts at irregular times
$contribution_big = 0.03					# 3% of members will give large amounts of money at irregular times
$contribution_onetime = 0.05				# 5% of members will be one time only donors 

$contribution_timespan = 60					# payments reach up to 60 months (5 years) back
$contribution_membership_fee = "50,00"		# 8,-€ membership fee
$contribution_membership_type = "Mitglied"	# set type


def init_file(filename, header)
	file = File::open(filename, mode: "w")
	file.write(header)
	file.write("\n")
	return file
end

# write contacts
print "Writing 'contacts.csv'..."
filename = "contacts.csv"
header = '"Vorname","Nachname","Email","Straße","Postleitzahl","Stadt","Land","Telefon (Phone)","Telefon (Mobile)"'
contactsFile = init_file(filename, header)
for i in 1..$contact_count
	# rotate the file
	if i % $max_entries_per_file == 0
		contactsFile.close()
		extension = '.' + (i / $max_entries_per_file).to_s
		contactsFile = init_file(filename + extension, header)
	end

	first_name = Faker::Name.first_name
	last_name = Faker::Name.last_name
	
	# make sure, that the email addresses are unique
	begin
		email = Faker::Internet.email(name: last_name)
	end while $emails.include?(email)
	$emails.add(email)
	$contributors.push(email)
	
	contactsFile.write( '"' + first_name + '",')
	contactsFile.write( '"' + last_name + '",')
	contactsFile.write( '"' + email + '",')
	contactsFile.write( '"' + Faker::Address.street_address + '",')
	contactsFile.write( '"' + Faker::Address.zip_code + '",')
	contactsFile.write( '"' + Faker::Address.city + '",')
	contactsFile.write( '"' + $country + '",')
	contactsFile.write( '"' + Faker::PhoneNumber.phone_number + '",')
	contactsFile.write( '"' + Faker::PhoneNumber.cell_phone + '"')
	contactsFile.write( "\n" )
end
contactsFile.close()
print "done.\n"


# write organizations
print "Writing 'organizations.csv'..."
filename = "organizations.csv"
header = '"Email","Organisationsname","Straße","Postleitzahl","Stadt","Land","Telefon","Telefon (Fax)","Website","Bezugsquelle","Ansprechpartner_Vorname","Ansprechpartner_Nachname","Ansprechpartner_Email","Ansprechpartner_Straße","Ansprechpartner_PLZ","Ansprechpartner_Ort","Ansprechpartner_Land","Ansprechpartner_Telefon(home)","Ansprechpartner_Berufsbezeichnung","Ansprechpartner_Quelle"'
organizationsFile = init_file(filename, header)
for i in 1..$organization_count
	# rotate the file
	if i % $max_entries_per_file == 0
		organizationsFile.close()
		extension = '.' + (i / $max_entries_per_file).to_s
		organizationsFile = init_file(filename + extension, header)
	end

	cname = Faker::Company.name
	zipcode = Faker::Address.zip_code
	domain = Faker::Internet.domain_name
	city = Faker::Address.city
	# make sure, that the organization's email addresses are unique
	email = "info@" + domain
	while $emails.include?(email) do
		email = Faker::Internet.user_name(specifier: cname) + '@' + domain
	end
	$emails.add(email)

	contact_first_name = Faker::Name.first_name
	contact_last_name = Faker::Name.last_name
	
	# make sure, that the contact's email addresses are unique
	begin
		contact_email = Faker::Internet.user_name(specifier: contact_last_name) + '@' + domain
	end while $emails.include?(contact_email)
	$emails.add(contact_email)
	
	organizationsFile.write( '"' + email + '",')
	organizationsFile.write( '"' + cname + '",')
	organizationsFile.write( '"' + Faker::Address.street_address + '",')
	organizationsFile.write( '"' + zipcode + '",')
	organizationsFile.write( '"' + city + '",')
	organizationsFile.write( '"' + $country + '",')
	organizationsFile.write( '"' + Faker::PhoneNumber.phone_number + '",')
	organizationsFile.write( '"' + Faker::PhoneNumber.phone_number + '",')
	organizationsFile.write( '"' + "http://www." + domain + '",')
	organizationsFile.write( '"' + $source + '",')
	
	# add contact person data
	organizationsFile.write( '"' + contact_first_name + '",')
	organizationsFile.write( '"' + contact_last_name + '",')
	organizationsFile.write( '"' + contact_email + '",')
	organizationsFile.write( '"' + Faker::Address.street_address + '",')
	organizationsFile.write( '"' + zipcode + '",')
	organizationsFile.write( '"' + city + '",')
	organizationsFile.write( '"' + $country + '",')
	organizationsFile.write( '"' + Faker::PhoneNumber.phone_number + '",')
	organizationsFile.write( '"RandomTitle",')
	organizationsFile.write( '"' + $source + '"')
	
	organizationsFile.write( "\n" )
end
organizationsFile.close()
print "done.\n"


# write contributions
print "Writing 'contributions.csv'..."
filename = "contributions.csv"
header = '"Email","Art der Zuwendung","Eingangsdatum","Gesamtbetrag","Herkunft","Betragsstatus"'
contribFile = init_file(filename, header)
i = 0

for email in $contributors

	if SecureRandom.random_number <= $contribution_member
		# this is a member
		# since_months must not be 0
		since_months = SecureRandom.random_number($contribution_timespan) + 1
		if SecureRandom.random_number <= 0.8
			# is still a member
			until_months = 0
		else
			# is not a member any more
			until_months = SecureRandom.random_number(since_months)
		end
		
		# save membership information for membership lists
		membership = {
			'email' => email,
			'start' => (Date.new($now.year, $now.month, 1) << since_months).strftime('%Y-%m-%d'),
			}
		membership['end'] = (Date.new($now.year, $now.month, 1) << until_months).strftime('%Y-%m-%d') if until_months > 0
		$members.push(membership)
		
		for month_back in until_months..since_months

			i += 1
			# rotate the file
			if i % $max_entries_per_file == 0
				contribFile.close()
				extension = '.' + (i / $max_entries_per_file).to_s
				contribFile = init_file(filename + extension, header)
			end

			date = Date.new($now.year, $now.month, 1) << month_back
			date = date + SecureRandom.random_number(2)
			date = date - SecureRandom.random_number(2)
			contribFile.write( '"' + email + '",')
			contribFile.write( '"Mitgliedsbeitrag",')
			contribFile.write( '"' + date.strftime('%Y-%m-%d') + '",')
			contribFile.write( '"' + $contribution_membership_fee + '",')
			contribFile.write( '"' + $source + '",')
			contribFile.write( '"Completed"')
			contribFile.write( "\n" )
		end
	end		# member
	
	if SecureRandom.random_number <= $contribution_small
		# this is a small amounts donor
		donation_count = SecureRandom.random_number($contribution_timespan/2)
		for donation in 1..donation_count

			i += 1
			# rotate the file
			if i % $max_entries_per_file == 0
				contribFile.close()
				extension = '.' + (i / $max_entries_per_file).to_s
				contribFile = init_file(filename + extension, header)
			end

			date = Date.new($now.year, $now.month, $now.day) - SecureRandom.random_number($contribution_timespan*30)
			date = Date.new($now.year, $now.month, $now.day) - SecureRandom.random_number($contribution_timespan*30)
			amount = 2 + 2 * SecureRandom.random_number(100)	# donates between 2 and 200 €
			contribFile.write( '"' + email + '",')
			contribFile.write( '"allgemeine Spende",')
			contribFile.write( '"' + date.strftime('%Y-%m-%d') + '",')
			contribFile.write( '"' + amount.to_s + ',00",')
			contribFile.write( '"' + $source + '",')
			contribFile.write( '"Completed"')
			contribFile.write( "\n" )
		end		# donation
	end		# small amounts donor
	
	if SecureRandom.random_number <= $contribution_big
		# this is a big amounts donor
		donation_count = SecureRandom.random_number($contribution_timespan/12)
		for donation in 1..donation_count

			i += 1
			# rotate the file
			if i % $max_entries_per_file == 0
				contribFile.close()
				extension = '.' + (i / $max_entries_per_file).to_s
				contribFile = init_file(filename + extension, header)
			end

			date = Date.new($now.year, $now.month, $now.day) - SecureRandom.random_number($contribution_timespan*30)
			amount = (10 + SecureRandom.random_number(10))*1000		# donates between 10.000 and 20.000 €
			contribFile.write( '"' + email + '",')
			contribFile.write( '"allgemeine Spende",')
			contribFile.write( '"' + date.strftime('%Y-%m-%d') + '",')
			contribFile.write( '"' + amount.to_s + ',00",')
			contribFile.write( '"' + $source + '",')
			contribFile.write( '"Completed"')
			contribFile.write( "\n" )
		end		# donation
	end		# big amounts donor

	if SecureRandom.random_number <= $contribution_onetime

		i += 1
		# rotate the file
		if i % $max_entries_per_file == 0
			contribFile.close()
			extension = '.' + (i / $max_entries_per_file).to_s
			contribFile = init_file(filename + extension, header)
		end

		# this is a one time donor
		date = Date.new($now.year, $now.month, $now.day) - SecureRandom.random_number($contribution_timespan*30)
		amount = (2 + SecureRandom.random_number(1000))*100		# donates between 200 and 200.000 €
		contribFile.write( '"' + email + '",')
		contribFile.write( '"Anlassspende",')
		contribFile.write( '"' + date.strftime('%Y-%m-%d') + '",')
		contribFile.write( '"' + amount.to_s + ',00",')
		contribFile.write( '"' + $source + '",')
		contribFile.write( '"abgeschlossen"')
		contribFile.write( "\n" )
	end		# one time donor
end

contribFile.close()
print "done.\n"



# write members
print "Writing 'memberships.csv'..."
filename = "memberships.csv"
header = '"Email","Mitglied seit","Ablaufdatum der Mitgliedschaft","Mitgliedstyp","Bezugsquelle"'
memberFile = init_file(filename, header)
i = 0

for membership in $members
	i += 1
	# rotate the file
	if i % $max_entries_per_file == 0
		memberFile.close()
		extension = '.' + (i / $max_entries_per_file).to_s
		memberFile = init_file(filename + extension, header)
	end

	memberFile.write( '"' + membership['email'] + '",')
	memberFile.write( '"' + membership['start'] + '",')
	if membership['end']
		memberFile.write( '"' + membership['end'] + '",')
	else
		memberFile.write( ',')
	end
	memberFile.write( '"' + $contribution_membership_type + '",')
	memberFile.write( '"' + $source + '"')
	memberFile.write( "\n" )
end

memberFile.close()
print "done.\n"
