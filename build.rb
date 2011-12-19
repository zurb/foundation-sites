#!/usr/bin/env ruby
require "sass"

# Creates a zip file of the Foundation template and the compessed assets

VERSION_STRING = '2.1.3'



def prepend_text(file_name, text)
  `exec 3<> '#{file_name}' && awk -v TEXT="#{text}" 'BEGIN {print TEXT}{print}' '#{file_name}' >&3`
end

`rm -rf public marketing/files/foundation-download.zip`
`jammit` # see config/assets.yml for details on what jammit is doing here
`mkdir public/src public/src/javascripts public/src/stylesheets`
`cp -R humans.txt images index.html robots.txt public/src`
`cp public/assets/foundation.js public/src/javascripts`
`cp stylesheets/ie.css public/src/stylesheets/ie.css`
`cp stylesheets/app.css public/src/stylesheets/app.css`
`cp javascripts/app.js public/src/javascripts/app.js`


# Merge the global.css, typography.css, grid.css, ui.css, forms.css, orbit.css, reveal.css, and mobile.css stylesheets
Dir.chdir('sass')
template = File.read("foundation.scss")
sass_engine = Sass::Engine.new(template, :syntax => :scss)
sass_output = sass_engine.render


Dir.chdir('..')
File.open('public/src/stylesheets/foundation.css', "w") do |file|  
  file.puts(sass_output)
end

file_name = 'public/src/index.html'

text = File.read(file_name)
text.gsub!(/<!-- Combine and Compress These CSS Files -->.+<!-- End Combine and Compress These CSS Files -->/m, "<link rel=\"stylesheet\" href=\"stylesheets/foundation.css\">")
text.gsub!(/<!-- Combine and Compress These JS Files -->.+<!-- End Combine and Compress These JS Files -->/m, "<script src=\"javascripts/foundation.js\"></script>")

File.open(file_name, "w") do |file|  
  file.puts text
end

%w{public/src/javascripts/app.js public/src/javascripts/foundation.js public/src/stylesheets/app.css public/src/stylesheets/foundation.css public/src/stylesheets/ie.css}.each do |file_name|
  prepend_text(file_name, "/* Foundation v#{VERSION_STRING} http://foundation.zurb.com */")
end

`cd public/src && zip -r ../../marketing/files/foundation-download-#{VERSION_STRING}.zip *`
`rm -rf public`
