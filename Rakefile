require "find"
task :md5 do
  md5sums = `makepkg -g`
  File.open('PKGBUILD', 'r+'){|io|
    updated = io.read.sub(/^\s*md5sums=\([^)]*\)$/, md5sums)
    io.truncate 0
    io.pos = 0
    io.write updated
  }
end

task :build_package => [:md5] do
  `makepkg -sf >&2` unless File.file?("pkg/etc/freeswitch/vars.xml")
end

task :repackage => [:make_pkgbuild] do
  `makepkg -Rf >&2`
end

task :make_pkgbuild => [:build_package] do
  files = Find.find("pkg/etc/freeswitch").entries.select do |f| 
    f.match(%r{default\.xml$|1000\.xml}) ||
    !f.match(%r{/lang/|/directory/default|/[dD]emo|[dD]emo\.|example}) && File.file?(f) 
  end.map { |n| n.sub(%r{pkg/},'') }
  old_pkgbuild = File.readlines("PKGBUILD")
  backup_index = old_pkgbuild.index { |line| line.match /^\s*backup=/ } || 0
  lines = old_pkgbuild[0 .. backup_index-1]
  lines << "backup=(#{files.each_slice(4).map { |line| line.map { |n| %Q{"#{n}"}}.join(" ") }.join("\n")})"
  File.open("PKGBUILD","w") { |f| f.puts lines.join }
end

task :release do
  `makepkg --source`
end

task :default => [:repackage, :release] do
  puts "Release is ready"
end
