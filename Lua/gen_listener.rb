require "find"

Find.find("./") do |path|
  unless File.file?(path) and path.include?(".lua")
    next
  end
  changed = false
  newContent = ""
  File.open(path, "r") do |io|
    content = io.read
    if content.include? ':Add('
      # newContent = content.gsub(/self\..*\.onClick:Add\(/) do |row|
      newContent = content.gsub(/\S+:Add\(/) do |row|
        listener = row.split(":")[0]
        "self:AddListener(#{listener},"
        # "self:AddListener(self.#{listener}.onClick,"
        # "self:AddListener(self.onClick,"
      end
      changed = true
    end
  end
  if changed 
    File.open(path, "w") do |io|
        io.write newContent
    end
  end
end