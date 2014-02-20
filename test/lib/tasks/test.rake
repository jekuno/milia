Rake.application.remove_task 'test'

task :test do |t|
  Rake::Task['test:units'].invoke
  Rake::Task['test:functionals'].invoke
end


