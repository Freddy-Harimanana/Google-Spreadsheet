#les require necessaire
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'google_drive'
require 'csv'

class Mairie #la classe Mairie où se trouve tous les methodes

	def page_web #la declaration de la page web
		page = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/val-d-oise.html"))
		return page
	end

	
	def get_townhall_email(townhall_url) #Collecte de l'email d'une mairie d'une ville du Val d'Oise
		page = Nokogiri::HTML(URI.open(townhall_url)) #/ on indique un site URL neutre qui sera indiqué dans la prochaine méthode
		tableau_email = []
		email = page.xpath('//*[contains(text(), "@")]').text
		ville = page.xpath('//*[contains(text(), "Adresse mairie de")]').text.split #/ on divise la string pour pouvoir récupérer uniquement le nom de la ville
		tableau_email.push({ville[3] => email})  #/ on indique la position du nom de la ville dans la string pour la récupérer
		puts tableau_email
	return tableau_email
	end


	def get_townhall_urls #Collecte de toutes les URLs des villes du Val d'Oise
		page = page_web
		tableau_url = []
		urls = page.xpath('//*[@class="lientxt"]/@href') 
			for url in urls do
			url = "http://annuaire-des-mairies.com" + url.text[1..-1]
			tableau_url.push(url)	
		end
	return tableau_url 
	end
	

	def scrapp_data #Synchronisation des noms des villes et des emails des mairies
		puts "Liste des adresse email des mairie de la ville de Val-d-oise".upcase
		puts "\n"
		tableau_url = get_townhall_urls
		for townhall_url in tableau_url do
			get_townhall_email(townhall_url)
		end
	end


	def json(get_townhall_urls) #json est une methode permet de créer, modifier, d ecrire un fichier de type json
		File.open("db/emails.json","w") do |x|
		x.write(get_townhall_urls.to_json)
		end
	end


	#spreadsheet est la methode permet de créer, modifier, ecrire un fichier contenant toutes les hash de toutes les mairies
	#Ce fichier est directement mis dans un google sheet
	def spreadsheet(get_townhall_urls) 
	 	session = GoogleDrive::Session.from_config("config.json")
  		 ws = session.spreadsheet_by_key("1Z3bJYVtkvbXnXamrD7GRFw9uak1i4aUha-69bhrIaPU").worksheets[0]
  	 	tableau_email_spreadsheet = get_townhall_urls 
  		i = 1
   			tableau_email_spreadsheet.each do |x|
    			ws[i, 1] = x.keys.join
    			ws[i, 2] = x.values.join
    			i += 1
  			end
  		ws.save
  	end


	#csv est la methode permet de créer, modifier, ecrire un fichier
	#contenant toutes les hash dans un fichier de type CVS
	def csv(get_townhall_urls)  
  		CSV.open("db/emails.csv", "wb") do |x|
   			 get_townhall_urls.each do |ou|
     	 	 x << [ou.keys.join, ou.values.join]
    		end 
  		end 
	end
	

	#run est une methode qui va executer toutes les méthodes que 
	# nous avons crées dans notre classe Mairie
	def run 
  		get_townhall_urls
  		json(get_townhall_urls)
  		spreadsheet(get_townhall_urls)
  		csv(get_townhall_urls)
	end

end

