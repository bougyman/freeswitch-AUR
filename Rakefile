require "find"
task :md5 do
  md5sums = `makepkg -g`
  old_pkgbuild = File.readlines("PKGBUILD")
  md_index = old_pkgbuild.index { |line| line.match /^\s*md5sums=/ } || 0
  top_of_pkgbuild = old_pkgbuild[0 .. md_index-1]
  end_index = old_pkgbuild[md_index .. -1].index { |l| l.match /\)$/} + md_index
  bottom_of_pkgbuild = old_pkgbuild[end_index+1 .. -1]
  File.open("PKGBUILD", "w") { |f| f.puts top_of_pkgbuild.join + md5sums + bottom_of_pkgbuild.join }
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
  lines << "backup=(#{files.shift}\n"
  files.each_slice(4) { |line| lines << "#{line.join(' ')}\n" }
  lines.last.sub!(/$/,")")
  File.open("PKGBUILD","w") { |f| f.puts lines.join }
end

task :release do
  `makepkg --source`
end

task :default => [:repackage, :release] do
  puts "Release is ready"
end
