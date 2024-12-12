#! /bin/sh

while getopts ":i:n:t:" arg; do
  case $arg in
    i) # Specify local image path.
      image_path="$OPTARG"
      ;;
    n) # Optional override for current filename
      image_name_arg="$OPTARG"
      ;;
    t) # Optional override for default_dir
      target_path_arg="$OPTARG"
      ;;
    g) # Set for all users - TODO
      ;;
    u) # set for a specific user - TODO
      ;;
    o) # set desired output [script/profile/command/policy]- TODO
      ;;
    a) # apply to Fleet - TODO
      ;;
  esac
  shift $((OPTIND-1))
done

# If no image path was passed as a flag and there was an unflagged argument, assume that was 
# the file path was passed without a flag
if [ -z $image_path ]; then image_path=$1; fi

# Parse args and set up default values
raw_name=${image_name_arg:-$(basename $image_path)}

# Verify that file exists and is an image, get file type
file_type=$(file --brief --mime-type "$image_path" | grep image | xargs basename )

echo $file_type

if [ -z $file_type ]; then 
  echo "No image found at $image_path - Please try again."
  exit 1 
fi

# Writing to file seems to require an extension for the decoded image 
# Not sure why/if that's something I can do better, but for now I'm enforcing 
# the extension pulled from the mime type

raw_name=${raw_name%%.*}
image_name=${raw_name}.${file_type}
target_dir=${target_dir_arg:-"/opt/orbit/images"}
generated_file="./set_${raw_name//[^a-zA-Z0-9]/_}_wallpaper"
image_base64=$(base64 -i "$image_path")

# The encoded image was too much for sed to handle. There may be a 
# better way of going about this, but for now, just manually inserting 
# the beginning of the file

echo $image_name
echo "#! bin/sh \n" > $generated_file
echo "image_base64=\"$image_base64\"" >> $generated_file


# Grab the rest of the script from the template file

sed  -e "s#{{target_dir}}#$target_dir#g"  \
     -e "s#{{image_name}}#$image_name#g" \
  ./templates/script.template >> $generated_file

chmod +x $generated_file

