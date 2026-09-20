export FILE=/path/to/script.tar.gz
echo ${FILE##*/}
echo ${FILE%.tar.gz}
echo ${FILE/path/dir}
