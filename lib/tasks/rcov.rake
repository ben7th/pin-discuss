namespace :test do
  desc 'Measures test coverage'
  task :rcov do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = %(rcov --rails --aggregate coverage.data --text-summary -Ilib --html -o doc/coverage test/*.rb)
    system rcov
    system "open doc/coverage/index.html" if PLATFORM['darwin']
  end
end
