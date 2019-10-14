require 'bundler/setup'
# require 'rubygems'
# gem 'google_drive'
require "google_drive"
 
#Google Drive
session = GoogleDrive::Session.from_config("client_secret.json")
sheet = session.spreadsheet_by_key("1E2B8MNLpZufT80eH493T6zzviXUXcbfYhADOfZVEITI").worksheets[0]
sheet[1, 1] = "update"
sheet.save
value = sheet[1,1]
p "the value is: " + value
