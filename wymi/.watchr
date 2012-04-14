watch("static/coffee/(.*).coffee") do |f|
  puts "Compiling #{f[0]}"
  `coffee -o static/js/ -c #{f[0]}`
end
