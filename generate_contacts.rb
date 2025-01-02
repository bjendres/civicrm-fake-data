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

# Define gendered name lists
male_names = ['Aaron', 'Abdul', 'Abdullah', 'Adam', 'Adrian', 'Adriano', 'Ahmad', 'Ahmed', 'Ahmet', 'Alan', 'Albert', 'Alessandro', 'Alessio', 'Alex', 'Alexander', 'Alfred', 'Ali', 'Amar', 'Amir', 'Amon', 'Andre', 'Andreas', 'Andrew', 'Angelo', 'Ansgar', 'Anthony', 'Anton', 'Antonio', 'Arda', 'Arian', 'Armin', 'Arne', 'Arno', 'Arthur', 'Artur', 'Arved', 'Arvid', 'Ayman', 'Baran', 'Baris', 'Bastian', 'Batuhan', 'Bela', 'Ben', 'Benedikt', 'Benjamin', 'Bennet', 'Bennett', 'Benno', 'Bent', 'Berat', 'Berkay', 'Bernd', 'Bilal', 'Bjarne', 'Björn', 'Bo', 'Boris', 'Brandon', 'Brian', 'Bruno', 'Bryan', 'Burak', 'Calvin', 'Can', 'Carl', 'Carlo', 'Carlos', 'Carsten', 'Caspar', 'Cedric', 'Cedrik', 'Cem', 'Charlie', 'Chris', 'Christian', 'Christiano', 'Christoph', 'Christopher', 'Claas', 'Clemens', 'Colin', 'Collin', 'Conner', 'Connor', 'Constantin', 'Corvin', 'Curt', 'Damian', 'Damien', 'Daniel', 'Danilo', 'Danny', 'Darian', 'Dario', 'Darius', 'Darren', 'David', 'Davide', 'Davin', 'Dean', 'Deniz', 'Dennis', 'Denny', 'Devin', 'Diego', 'Dion', 'Domenic', 'Domenik', 'Dominic', 'Dominik', 'Dorian', 'Dustin', 'Dylan', 'Ecrin', 'Eddi', 'Eddy', 'Edgar', 'Edwin', 'Efe', 'Ege', 'Elia', 'Eliah', 'Elias', 'Elijah', 'Emanuel', 'Emil', 'Emilian', 'Emilio', 'Emir', 'Emirhan', 'Emre', 'Enes', 'Enno', 'Enrico', 'Eren', 'Eric', 'Erik', 'Etienne', 'Fabian', 'Fabien', 'Fabio', 'Fabrice', 'Falk', 'Felix', 'Ferdinand', 'Fiete', 'Filip', 'Finlay', 'Finley', 'Finn', 'Finnley', 'Florian', 'Francesco', 'Franz', 'Frederic', 'Frederick', 'Frederik', 'Friedrich', 'Fritz', 'Furkan', 'Fynn', 'Gabriel', 'Georg', 'Gerrit', 'Gian', 'Gianluca', 'Gino', 'Giuliano', 'Giuseppe', 'Gregor', 'Gustav', 'Hagen', 'Hamza', 'Hannes', 'Hanno', 'Hans', 'Hasan', 'Hassan', 'Hauke', 'Hendrik', 'Hennes', 'Henning', 'Henri', 'Henrick', 'Henrik', 'Henry', 'Hugo', 'Hussein', 'Ian', 'Ibrahim', 'Ilias', 'Ilja', 'Ilyas', 'Immanuel', 'Ismael', 'Ismail', 'Ivan', 'Iven', 'Jack', 'Jacob', 'Jaden', 'Jakob', 'Jamal', 'James', 'Jamie', 'Jan', 'Janek', 'Janis', 'Janne', 'Jannek', 'Jannes', 'Jannik', 'Jannis', 'Jano', 'Janosch', 'Jared', 'Jari', 'Jarne', 'Jarno', 'Jaron', 'Jason', 'Jasper', 'Jay', 'Jayden', 'Jayson', 'Jean', 'Jens', 'Jeremias', 'Jeremie', 'Jeremy', 'Jermaine', 'Jerome', 'Jesper', 'Jesse', 'Jim', 'Jimmy', 'Joe', 'Joel', 'Joey', 'Johann', 'Johannes', 'John', 'Johnny', 'Jon', 'Jona', 'Jonah', 'Jonas', 'Jonathan', 'Jonte', 'Joost', 'Jordan', 'Joris', 'Joscha', 'Joschua', 'Josef', 'Joseph', 'Josh', 'Joshua', 'Josua', 'Juan', 'Julian', 'Julien', 'Julius', 'Juri', 'Justin', 'Justus', 'Kaan', 'Kai', 'Kalle', 'Karim', 'Karl', 'Karlo', 'Kay', 'Keanu', 'Kenan', 'Kenny', 'Keno', 'Kerem', 'Kerim', 'Kevin', 'Kian', 'Kilian', 'Kim', 'Kimi', 'Kjell', 'Klaas', 'Klemens', 'Konrad', 'Konstantin', 'Koray', 'Korbinian', 'Kurt', 'Lars', 'Lasse', 'Laurence', 'Laurens', 'Laurenz', 'Laurin', 'Lean', 'Leander', 'Leandro', 'Leif', 'Len', 'Lenn', 'Lennard', 'Lennart', 'Lennert', 'Lennie', 'Lennox', 'Lenny', 'Leo', 'Leon', 'Leonard', 'Leonardo', 'Leonhard', 'Leonidas', 'Leopold', 'Leroy', 'Levent', 'Levi', 'Levin', 'Lewin', 'Lewis', 'Liam', 'Lian', 'Lias', 'Lino', 'Linus', 'Lio', 'Lion', 'Lionel', 'Logan', 'Lorenz', 'Lorenzo', 'Loris', 'Louis', 'Luan', 'Luc', 'Luca', 'Lucas', 'Lucian', 'Lucien', 'Ludwig', 'Luis', 'Luiz', 'Luk', 'Luka', 'Lukas', 'Luke', 'Lutz', 'Maddox', 'Mads', 'Magnus', 'Maik', 'Maksim', 'Malik', 'Malte', 'Manuel', 'Marc', 'Marcel', 'Marco', 'Marcus', 'Marek', 'Marian', 'Mario', 'Marius', 'Mark', 'Marko', 'Markus', 'Marlo', 'Marlon', 'Marten', 'Martin', 'Marvin', 'Marwin', 'Mateo', 'Mathis', 'Matis', 'Mats', 'Matteo', 'Mattes', 'Matthias', 'Matthis', 'Matti', 'Mattis', 'Maurice', 'Max', 'Maxim', 'Maximilian', 'Mehmet', 'Meik', 'Melvin', 'Merlin', 'Mert', 'Michael', 'Michel', 'Mick', 'Miguel', 'Mika', 'Mikail', 'Mike', 'Milan', 'Milo', 'Mio', 'Mirac', 'Mirco', 'Mirko', 'Mohamed', 'Mohammad', 'Mohammed', 'Moritz', 'Morten', 'Muhammed', 'Murat', 'Mustafa', 'Nathan', 'Nathanael', 'Nelson', 'Neo', 'Nevio', 'Nick', 'Niclas', 'Nico', 'Nicolai', 'Nicolas', 'Niels', 'Nikita', 'Niklas', 'Niko', 'Nikolai', 'Nikolas', 'Nils', 'Nino', 'Noah', 'Noel', 'Norman', 'Odin', 'Oke', 'Ole', 'Oliver', 'Omar', 'Onur', 'Oscar', 'Oskar', 'Pascal', 'Patrice', 'Patrick', 'Paul', 'Peer', 'Pepe', 'Peter', 'Phil', 'Philip', 'Philipp', 'Pierre', 'Piet', 'Pit', 'Pius', 'Quentin', 'Quirin', 'Rafael', 'Raik', 'Ramon', 'Raphael', 'Rasmus', 'Raul', 'Rayan', 'René', 'Ricardo', 'Riccardo', 'Richard', 'Rick', 'Rico', 'Robert', 'Robin', 'Rocco', 'Roman', 'Romeo', 'Ron', 'Ruben', 'Ryan', 'Said', 'Salih', 'Sam', 'Sami', 'Sammy', 'Samuel', 'Sandro', 'Santino', 'Sascha', 'Sean', 'Sebastian', 'Selim', 'Semih', 'Shawn', 'Silas', 'Simeon', 'Simon', 'Sinan', 'Sky', 'Stefan', 'Steffen', 'Stephan', 'Steve', 'Steven', 'Sven', 'Sönke', 'Sören', 'Taha', 'Tamino', 'Tammo', 'Tarik', 'Tayler', 'Taylor', 'Teo', 'Theo', 'Theodor', 'Thies', 'Thilo', 'Thomas', 'Thorben', 'Thore', 'Thorge', 'Tiago', 'Til', 'Till', 'Tillmann', 'Tim', 'Timm', 'Timo', 'Timon', 'Timothy', 'Tino', 'Titus', 'Tizian', 'Tjark', 'Tobias', 'Tom', 'Tommy', 'Toni', 'Tony', 'Torben', 'Tore', 'Tristan', 'Tyler', 'Tyron', 'Umut', 'Uwe', 'Valentin', 'Valentino', 'Veit', 'Victor', 'Viktor', 'Vin', 'Vincent', 'Vito', 'Vitus', 'Wilhelm', 'Willi', 'William', 'Willy', 'Xaver', 'Yannic', 'Yannick', 'Yannik', 'Yannis', 'Yasin', 'Youssef', 'Yunus', 'Yusuf', 'Yven', 'Yves', 'Ömer']

female_names = ['Aaliyah', 'Abby', 'Abigail', 'Ada', 'Adelina', 'Adriana', 'Aileen', 'Aimee', 'Alana', 'Alea', 'Alena', 'Alessa', 'Alessia', 'Alexa', 'Alexandra', 'Alexia', 'Alexis', 'Aleyna', 'Alia', 'Alica', 'Alice', 'Alicia', 'Alina', 'Alisa', 'Alisha', 'Alissa', 'Aliya', 'Aliyah', 'Allegra', 'Alma', 'Alyssa', 'Amalia', 'Amanda', 'Amelia', 'Amelie', 'Amina', 'Amira', 'Amy', 'Ana', 'Anabel', 'Anastasia', 'Andrea', 'Angela', 'Angelina', 'Angelique', 'Anja', 'Ann', 'Anna', 'Annabel', 'Annabell', 'Annabelle', 'Annalena', 'Anne', 'Anneke', 'Annelie', 'Annemarie', 'Anni', 'Annie', 'Annika', 'Anny', 'Anouk', 'Antonia', 'Arda', 'Ariana', 'Ariane', 'Arwen', 'Ashley', 'Asya', 'Aurelia', 'Aurora', 'Ava', 'Ayleen', 'Aylin', 'Ayse', 'Azra', 'Betty', 'Bianca', 'Bianka', 'Brigitte', 'Caitlin', 'Cara', 'Carina', 'Carla', 'Carlotta', 'Carmen', 'Carolin', 'Carolina', 'Caroline', 'Cassandra', 'Catharina', 'Catrin', 'Cecile', 'Cecilia', 'Celia', 'Celina', 'Celine', 'Ceyda', 'Ceylin', 'Chantal', 'Charleen', 'Charlotta', 'Charlotte', 'Chayenne', 'Cheyenne', 'Chiara', 'Christin', 'Christiane', 'Christina', 'Cindy', 'Claire', 'Clara', 'Clarissa', 'Colleen', 'Collien', 'Cora', 'Corinna', 'Cosima', 'Dana', 'Daniela', 'Daria', 'Darleen', 'Defne', 'Delia', 'Denise', 'Diana', 'Dilara', 'Dina', 'Dorothea', 'Ecrin', 'Eda', 'Eileen', 'Ela', 'Elaine', 'Elanur', 'Elea', 'Elena', 'Eleni', 'Eleonora', 'Eliana', 'Elif', 'Elina', 'Elisa', 'Elisabeth', 'Ella', 'Ellen', 'Elli', 'Elly', 'Elsa', 'Emelie', 'Emely', 'Emilia', 'Emilie', 'Emily', 'Emma', 'Emmely', 'Emmi', 'Emmy', 'Enie', 'Enna', 'Enya', 'Esma', 'Estelle', 'Esther', 'Eva', 'Evelin', 'Evelina', 'Eveline', 'Evelyn', 'Fabienne', 'Fatima', 'Fatma', 'Felicia', 'Felicitas', 'Felina', 'Femke', 'Fenja', 'Fine', 'Finia', 'Finja', 'Finnja', 'Fiona', 'Flora', 'Florentine', 'Francesca', 'Franka', 'Franziska', 'Frederike', 'Freya', 'Frida', 'Frieda', 'Friederike', 'Giada', 'Gina', 'Giulia', 'Giuliana', 'Greta', 'Hailey', 'Hana', 'Hanna', 'Hannah', 'Heidi', 'Helen', 'Helena', 'Helene', 'Helin', 'Henriette', 'Henrike', 'Hermine', 'Ida', 'Ilayda', 'Imke', 'Ina', 'Ines', 'Inga', 'Inka', 'Irem', 'Isa', 'Isabel', 'Isabell', 'Isabella', 'Isabelle', 'Ivonne', 'Jacqueline', 'Jamie', 'Jamila', 'Jana', 'Jane', 'Janin', 'Janina', 'Janine', 'Janna', 'Janne', 'Jara', 'Jasmin', 'Jasmina', 'Jasmine', 'Jella', 'Jenna', 'Jennifer', 'Jenny', 'Jessica', 'Jessy', 'Jette', 'Jil', 'Jill', 'Joana', 'Joanna', 'Joelina', 'Joeline', 'Joelle', 'Johanna', 'Joleen', 'Jolie', 'Jolien', 'Jolin', 'Jolina', 'Joline', 'Jona', 'Jonah', 'Jonna', 'Josefin', 'Josefine', 'Josephin', 'Josephine', 'Josie', 'Josy', 'Joy', 'Joyce', 'Judith', 'Judy', 'Jule', 'Julia', 'Juliana', 'Juliane', 'Julie', 'Julienne', 'Julika', 'Julina', 'Juna', 'Justine', 'Kaja', 'Karina', 'Karla', 'Karlotta', 'Karolina', 'Karoline', 'Kassandra', 'Katarina', 'Katharina', 'Kathrin', 'Katja', 'Katrin', 'Kaya', 'Kayra', 'Kiana', 'Kiara', 'Kim', 'Kimberley', 'Kimberly', 'Kira', 'Klara', 'Korinna', 'Kristin', 'Kyra', 'Laila', 'Lana', 'Lara', 'Larissa', 'Laura', 'Laureen', 'Lavinia', 'Lea', 'Leah', 'Leana', 'Leandra', 'Leann', 'Lee', 'Leila', 'Lena', 'Lene', 'Leni', 'Lenia', 'Lenja', 'Lenya', 'Leona', 'Leoni', 'Leonie', 'Leonora', 'Leticia', 'Letizia', 'Levke', 'Leyla', 'Lia', 'Liah', 'Liana', 'Lili', 'Lilia', 'Lilian', 'Liliana', 'Lilith', 'Lilli', 'Lillian', 'Lilly', 'Lily', 'Lina', 'Linda', 'Lindsay', 'Line', 'Linn', 'Linnea', 'Lisa', 'Lisann', 'Lisanne', 'Liv', 'Livia', 'Liz', 'Lola', 'Loreen', 'Lorena', 'Lotta', 'Lotte', 'Louisa', 'Louise', 'Luana', 'Luca', 'Lucia', 'Lucie', 'Lucienne', 'Lucy', 'Luisa', 'Luise', 'Luka', 'Luna', 'Luzie', 'Lya', 'Lydia', 'Lyn', 'Lynn', 'Madeleine', 'Madita', 'Madleen', 'Madlen', 'Magdalena', 'Maike', 'Mailin', 'Maira', 'Maja', 'Malena', 'Malia', 'Malin', 'Malina', 'Mandy', 'Mara', 'Marah', 'Mareike', 'Maren', 'Maria', 'Mariam', 'Marie', 'Marieke', 'Mariella', 'Marika', 'Marina', 'Marisa', 'Marissa', 'Marit', 'Marla', 'Marleen', 'Marlen', 'Marlena', 'Marlene', 'Marta', 'Martha', 'Mary', 'Maryam', 'Mathilda', 'Mathilde', 'Matilda', 'Maxi', 'Maxima', 'Maxine', 'Maya', 'Mayra', 'Medina', 'Medine', 'Meike', 'Melanie', 'Melek', 'Melike', 'Melina', 'Melinda', 'Melis', 'Melisa', 'Melissa', 'Merle', 'Merve', 'Meryem', 'Mette', 'Mia', 'Michaela', 'Michelle', 'Mieke', 'Mila', 'Milana', 'Milena', 'Milla', 'Mina', 'Mira', 'Miray', 'Miriam', 'Mirja', 'Mona', 'Monique', 'Nadine', 'Nadja', 'Naemi', 'Nancy', 'Naomi', 'Natalia', 'Natalie', 'Nathalie', 'Neele', 'Nela', 'Nele', 'Nelli', 'Nelly', 'Nia', 'Nicole', 'Nika', 'Nike', 'Nikita', 'Nila', 'Nina', 'Nisa', 'Noemi', 'Nora', 'Olivia', 'Patricia', 'Patrizia', 'Paula', 'Paulina', 'Pauline', 'Penelope', 'Philine', 'Phoebe', 'Pia', 'Rahel', 'Rania', 'Rebecca', 'Rebekka', 'Riana', 'Rieke', 'Rike', 'Romina', 'Romy', 'Ronja', 'Rosa', 'Rosalie', 'Ruby', 'Sabrina', 'Sahra', 'Sally', 'Salome', 'Samantha', 'Samia', 'Samira', 'Sandra', 'Sandy', 'Sanja', 'Saphira', 'Sara', 'Sarah', 'Saskia', 'Selin', 'Selina', 'Selma', 'Sena', 'Sidney', 'Sienna', 'Silja', 'Sina', 'Sinja', 'Smilla', 'Sofia', 'Sofie', 'Sonja', 'Sophia', 'Sophie', 'Soraya', 'Stefanie', 'Stella', 'Stephanie', 'Stina', 'Sude', 'Summer', 'Susanne', 'Svea', 'Svenja', 'Sydney', 'Tabea', 'Talea', 'Talia', 'Tamara', 'Tamia', 'Tamina', 'Tanja', 'Tara', 'Tarja', 'Teresa', 'Tessa', 'Thalea', 'Thalia', 'Thea', 'Theresa', 'Tia', 'Tina', 'Tomke', 'Tuana', 'Valentina', 'Valeria', 'Valerie', 'Vanessa', 'Vera', 'Veronika', 'Victoria', 'Viktoria', 'Viola', 'Vivian', 'Vivien', 'Vivienne', 'Wibke', 'Wiebke', 'Xenia', 'Yara', 'Yaren', 'Yasmin', 'Ylvi', 'Ylvie', 'Yvonne', 'Zara', 'Zehra', 'Zeynep', 'Zoe', 'Zoey', 'Zoé']

# Function to determine gender
def determine_gender(first_name, male_names, female_names)
  return 'divers' if rand < 0.08 # 8% chance for "Divers"
  return 'männlich' if male_names.include?(first_name)
  return 'weiblich' if female_names.include?(first_name)
  'Unbekannt' # Fallback if the name is not in either list
end

# write contacts
print "Writing 'contacts.csv'..."
filename = "contacts.csv"
header = '"Vorname","Nachname","Email","Straße","Postleitzahl","Stadt","Land","Telefon (Phone)","Telefon (Mobile)","Gender","Geburtsdatum"'
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
  
  # Determine gender based on first name or randomize for "Divers"
  gender = determine_gender(first_name, male_names, female_names)
  
  # make sure, that the email addresses are unique
  begin
    email = Faker::Internet.email(name: last_name)
  end while $emails.include?(email)
  $emails.add(email)
  $contributors.push(email)

  # generate random birthdate between 1950 and 2010
  birth_date = Faker::Date.between(from: '1950-01-01', to: '2010-12-31').strftime('%Y-%m-%d')

  contactsFile.write( '"' + first_name + '",')
  contactsFile.write( '"' + last_name + '",')
  contactsFile.write( '"' + email + '",')
  contactsFile.write( '"' + Faker::Address.street_address + '",')
  contactsFile.write( '"' + Faker::Address.zip_code + '",')
  contactsFile.write( '"' + Faker::Address.city + '",')
  contactsFile.write( '"' + $country + '",')
  contactsFile.write( '"' + Faker::PhoneNumber.phone_number + '",')
  contactsFile.write( '"' + Faker::PhoneNumber.cell_phone + '",')
  contactsFile.write( '"' + gender + '",') 
  contactsFile.write( '"' + birth_date + '"')
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