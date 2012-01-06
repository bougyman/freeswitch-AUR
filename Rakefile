require "find"
task :build_package do
  `makepkg -s >&2` unless File.file?("pkg/etc/freeswitch/vars.xml")
end

task :make_pkgbuild => [:build_package] do
  files = Find.find("pkg/etc/freeswitch").entries.select do |f| 
    f.match(%r{default\.xml$|1000\.xml}) ||
    !f.match(%r{/lang/|/directory/default|/[dD]emo|[dD]emo\.|example}) && File.file?(f) 
  end.map { |n| n.sub(%r{pkg/},'') }
  old_pkgbuild = File.readlines("PKGBUILD")
  backup_index = old_pkgbuild.index { |line| line.match /^\s*backup=/ } || 0
  lines = old_pkgbuild[0 .. backup_index-1]
  lines << "backup=(#{files.shift}\n"
  files.each_slice(4) { |line| lines << "#{line.join(' ')}\n" }
  lines.last.sub!(/$/,")")
  File.open("PKGBUILD","w") { |f| f.puts lines.join }
end

task :default => [:make_pkgbuild] do
end
