tables = ActiveRecord::Base.connection.tables
puts "Tables: #{tables.count}"

def process_table(klass)
  klass.column_names.map do |column|
    {
      column => column.titleize
    }
  end.reduce({}, :merge)
end

en = { activerecord: { attributes: {} } }

tables.each do |table|
  klass = table.classify.constantize rescue nil
  next if klass.nil?
  
  en[:activerecord][:attributes][table.singularize] = process_table(klass)
end

pp en

File.open('tmp/en.yml', 'w') do |file|
  file.write(YAML.dump(en))
end
