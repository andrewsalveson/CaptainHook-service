#user arguments 
model_path = ARGV[0]
compare_model_path = ARGV[1]

# require 'neverneverland'
# require 'csv'

    # puts "model_path: #{model_path}"
    # puts "compare_model_path: #{compare_model_path}"

require '/usr/local/lib/openstudio-1.14.0/ruby/2.0/openstudio.rb'

#example
#ruby osm_diff.rb "C:/Users/mdahlhausen/Desktop/CaptHook/test.osm" "C:/Users/mdahlhausen/Desktop/CaptHook/test2.osm" "C:/Users/mdahlhausen/Desktop/CaptHook"

def osm_diff(model_path, compare_model_path)
    
    puts "model_path: #{model_path}"
    puts "compare_model_path: #{compare_model_path}"
    
    
    # load the models
    vt = OpenStudio::OSVersion::VersionTranslator.new
    model = vt.loadModel(model_path)
    if model.empty?
      puts "Cannot load model from #{model_path} for comparison."
      return false
    end
    model = model.get
    compare_model = vt.loadModel(compare_model_path)
    if compare_model.empty?
      puts "Cannot load model from #{compare_model_path} for comparison."
      return false
    end
    compare_model = compare_model.get
    
    only_model = []
    only_compare = []
    both = []
    diffs = []
    num_ignored = 0
    
    # loop through model and find objects in this model only or in both
    model.getModelObjects.each do |object|
    
      # TODO: compare these some other way
      if not object.iddObject.hasNameField
        num_ignored += 1
        next
      end

      compare_object = compare_model.getObjectByTypeAndName(object.iddObject.type, object.name.to_s)
      if compare_object.empty?
        only_model << object
      else 
        both << [object, compare_object.get]
      end
    end 
    
    # loop through model and find objects in comparison model only
    compare_model.getModelObjects.each do |compare_object|
    
      # TODO: compare these some other way
      if not compare_object.iddObject.hasNameField
        num_ignored += 1
        next
      end
      
      object = model.getObjectByTypeAndName(compare_object.iddObject.type, compare_object.name.to_s)
      if object.empty?
        only_compare << compare_object
      end
    end 
    
    # loop through and perform the diffs 
    both.each do |b|
      object = b[0]
      compare_object = b[1]
      idd_object = object.iddObject
      
      object_num_fields = object.numFields
      compare_num_fields = compare_object.numFields
      
      diff = "<table border='1'>\n"
      diff += "<tr style='font-weight:bold'><td>#{object.iddObject.name}</td><td/><td/></tr>\n"
      diff += "<tr style='font-weight:bold'><td>Model Object</td><td>Comparison Object</td><td>Field Name</td></tr>\n"
      
      # loop over fields skipping handle
      same = true
      (1...[object_num_fields, compare_num_fields].max).each do |i|
      
        field_name = idd_object.getField(i).get.name
        
        object_value = ""
        if i < object_num_fields
          object_value = object.getString(i).to_s
        end
        object_value = "-" if object_value.empty?
        
        compare_value = ""
        if i < compare_num_fields
          compare_value = compare_object.getString(i).to_s
        end
        compare_value = "-" if compare_value.empty?
        
        row_color = "green"
        if object_value != compare_value
          same = false
          row_color = "red"
        end
        
        diff += "<tr><td style='color:#{row_color}'>#{object_value}</td><td style='color:#{row_color}'>#{compare_value}</td><td>#{field_name}</td></tr>\n"
        
      end
      diff += "</table><p/><p/>\n"
      
      if not same
        diffs << diff
      end

    end
       
    # write the report
    #File.open(report_path, 'w') do |file|
    file = []
      file << "<section>\n<h1>#{num_ignored} objects did not have names and were not compared</h1>\n"
      file << "</section>\n"
      
      file << "<table border='1'>\n"
      file << "<section>\n<h1>Objects Only In Model</h1>\n"
      file << "<table border='1'>\n"
      only_model.each do |object|
        file << "<tr><td style='white-space:pre'>#{object.to_s}</td></tr>\n"
      end
      file << "</table>\n"
      file << "</section>\n"
      
      file << "<section>\n<h1>Objects Only In Comparison Model</h1>\n"
      file << "<table border='1'>\n"
      only_compare.each do |object|
        file << "<tr><td style='white-space:pre'>#{object.to_s}</td></tr>\n"
      end
      file << "</table>\n"
      file << "</section>\n"
    
      file << "<section>\n<h1>Objects In Both Models With Differences</h1>\n"
      diffs.each do |diff|
        file << diff
      end
      file << "</section>\n"
    #end
  
    #puts "Report generated at: <a href='file:///#{report_path}'>#{report_path}</a>")
    #puts "#{num_ignored} objects did not have names and were not compared"
    puts file
    
    return true
end #end osm_diff

#call differencing function
#puts prints html content to stdout
if(model_path && compare_model_path)then
  run_success = osm_diff(model_path, compare_model_path)
else
  raise 'path is nil'
end