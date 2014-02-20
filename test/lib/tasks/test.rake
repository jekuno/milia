Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

Rake.application.remove_task 'test'

task :test do |t|
  Rake::Task['test:units'].invoke
  Rake::Task['test:functionals'].invoke
end


