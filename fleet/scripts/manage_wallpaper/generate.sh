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
    g) # Set for all users 
      global=true
      ;;
    u) #set for a specific user
      target_user="$OPTARG"
  esac
done

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
file_type=${file_type#*/}
image_name=${raw_name}.${file_type}
target_dir=${target_dir_arg:-"/opt/orbit/images"}
generated_file="./set_${raw_name//[^a-zA-Z0-9]/_}_wallpaper"
image_base64=$(base64 -i "$image_path")

echo $image_name
echo "#! bin/sh \n" > $generated_file
echo "image_base64=\"$image_base64\"" >> $generated_file


sed  -e "s#{{target_dir}}#$target_dir#g"  \
     -e "s#{{image_name}}#$image_name#g" \
  ./templates/script.template >> $generated_file

chmod +x $generated_file

