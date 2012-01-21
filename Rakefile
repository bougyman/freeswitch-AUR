require "find"
task :md5 do
  md5sums = `makepkg -g`.chomp
  File.open('PKGBUILD', 'r+'){|io|
    updated = io.read.sub(/^\s*md5sums=\([^)]*\)$/, md5sums)
    io.truncate 0
    io.pos = 0
    io.write updated
  }
end

task :build_package => [:md5] do
  `makepkg -sf >&2` unless File.file?("pkg/etc/sv/freeswitch/run")
end

task :repackage => [:build_package] do
  `makepkg -Rf >&2`
end

task :release do
  `makepkg --source`
end

task :default => [:repackage, :release] do
  puts "Release is ready"
end
