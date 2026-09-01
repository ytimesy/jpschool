namespace :content do
  desc "Validate versioned lesson content YAML"
  task validate: :environment do
    result = Content::Validator.new.call

    if result.issues.empty?
      puts "content:validate OK"
    else
      puts "severity | file | lesson | content_id | field | reason"
      result.issues.each { |issue| puts issue }
    end

    abort "content:validate failed with #{result.errors.length} error(s)" unless result.success?
  end
end
