sudo docker run -dti \
  -p $4:$4 \
  --env NODE_ENV=$3 \
  --name $2 \
  $1/$2