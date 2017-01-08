#requires OpenStudio 2.0 with command line interface installed

# $1 is old_model
# $2 is compare_model
# $3 is weather_file
old_model=$1
compare_model=$2
weather_file=$3

#need to create temp directory
#store files in a folder labeled "files"
#copy "ReportModelChanges" to a folder named "measures"
#output results are in folder "reports"

#osw_filename=
rm workflow.osw

echo "{'seed_file': '"$old_model"',  
  'weather_file': '"$weather_file"',
  'steps': [
    {
      'measure_dir_name': 'ReportModelChanges',
      'arguments': {
        'compare_model_path': '"$compare_model"'
      }
    }    
  ]
}" >> workflow.osw

#only runs diff measure
#openstudio run --measures_only

#runs diff measure and model energy use
openstudio run -w workflow.osw

#clean up here