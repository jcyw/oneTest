require "find"

amount = 0
imports = ""

Find.find("./") do |path|
  File.open(path, "r") do |io|
    unless File.file?(path) and path.include?(".lua")
      next
    end
    content = io.read
    if content.include? 'fgui.register_extension("ui'
      amount += 1
      path = path.gsub("./", "").gsub(".lua", "")
      puts path
      imports += %Q(import("#{path}")\n)
    end
  end
end

File.open("RequireExtensions.lua", "w") do |io|
  io.write imports
end
