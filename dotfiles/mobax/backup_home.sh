rm -rf home.tar.gz

tar -czvf home.tar.gz * \
 --exclude=".ssh" \
 --exclude=".bash_history" \
 --exclude="*.tar.gz" \
 --exclude="*.ssh"
