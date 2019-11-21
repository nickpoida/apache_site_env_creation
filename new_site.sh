#!/bin/bash
if [ "$(whoami)" != "root" ]; then
echo "Root privileges are required to run this, try running with sudo..."
exit 2
fi
current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
web_root="/var/www/"
site_url=0
password=0
while getopts ":u:p:" o; do
case "${o}" in
u)
site_url=${OPTARG}
;;
p)
password=${OPTARG}
;;
esac
done
if [ $site_url == 0 ]; then
read -p "Vvedite adres saita: " site_url
fi
if [ $password == 0 ]; then
read -p "Vvedite parol ftp" password
fi
absolute_doc_root=$web_root$site_url
if [ ! -d "$absolute_doc_root" ]; then
`mkdir "$absolute_doc_root/"`
`mkdir "$absolute_doc_root/public_html/"`
`chown -R apache:apache "$absolute_doc_root/"`
indexfile="$absolute_doc_root/public_html/index.html"
`touch "$indexfile"`
`chown apache:apache "$indexfile"`
echo "<html><head></head><body>Welcome to $site_url</body></html>" >> "$indexfile"
echo "Zaversheno sozdanie directorii saita"
fi
echo "<VirtualHost *:80>
    ServerName www.$site_url
    ServerAlias $site_url
    DocumentRoot /var/www/$site_url/public_html/
    ErrorLog /var/www/$site_url/error.log
    CustomLog /var/www/$site_url/requests.log combined
</VirtualHost>" > /etc/httpd/conf.d/$site_url.conf
echo "Zaversheno sozdanie configa apache"
echo "$site_url" >> /etc/vsftpd/virt_users
echo "$password" >> /etc/vsftpd/virt_users
db_load -T -t hash -f /etc/vsftpd/virt_users /etc/vsftpd/virt_users.db
echo "Zaversheno sozdanie FTP akkaunta"
systemctl restart vsftpd
systemctl restart httpd
echo "Service perezapushen"
echo " "
echo "Dlya podklucheniya ispolzuite"
echo "Hostname ftp://$site_url"
echo "Username : $site_url"
echo "Password : $password"
echo " "
echo "Ne zabudte ispravit DNS-zapisi"

exit 0
