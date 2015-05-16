require 'erb'

current_dir = File.dirname(__FILE__)
post_dir = File.join(current_dir, '_posts')

namespace :post do
  task :new, :title, :tags do |t, args|
    template = File.read(File.join(current_dir, '_tasks', 'post.erb'))
    date = Time.new
    title = args[:title]

    if title == nil 
      STDOUT.puts "Title: "
      title = STDIN.gets.chomp
    end

    tags = args[:tags]

    if tags == nil 
      STDOUT.puts "Categories: "
      tags = STDIN.gets.chomp
    end

    tags = tags.split(" ")
    layout = "post"

    md_file = ERB.new(template).result(binding)
    slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

    destination = File.join(post_dir, "#{date.strftime("%Y-%m-%d")}-#{slug}.markdown")
    File.open(destination, "w") do |f|
      f.write md_file
    end
    p "Created #{destination}"
  end
end

namespace :page do
  task :new, :title, :layout do |t, args|
    template = File.read(File.join(current_dir, '_tasks', 'page.erb'))
    date = Time.new
    title = args[:title]

    if title == nil 
      STDOUT.puts "Title: "
      title = STDIN.gets.chomp
    end

    layout = args[:layout] || "default"
    slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    md_file = ERB.new(template).result(binding)
    

    destination = File.join(current_dir, "#{slug}.html")
    File.open(destination, "w") do |f|
      f.write md_file
    end
    p "Created #{destination}"
  end
end