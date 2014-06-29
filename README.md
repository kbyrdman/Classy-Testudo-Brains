Classy-Testudo-Brains
=====================

Sinatra app for scraping UMD waitlists 


	USAGE
---------------

 - For entire scrape
 	> options = {}
	> Classy::Testudo::ScraperBot.scrape(options)  


 - scraping one department
	
	1) create a session and navigate to the department page

	> session = Capybara::Session.new :poltergeist

	> session.visit "www.department.com"

    2) create a Department class with the session

	> dep = UMD::Waitlist::Department.new session
	
	> dep.scrape


	Starting Thin server
__________________________

thin -R config.ru -p 3000 start
