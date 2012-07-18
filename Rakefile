task :web do 
  sh "cd 0x65.io; middleman"
end

task :build do 
  sh "cd 0x65.io; middleman build"
end

task :upload do 
  sh %{ncftpput -u "user" -p "password" -R host /public_html/0x65 0x65.io/build/*}
end
