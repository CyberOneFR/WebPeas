#!/bin/sh

if [ ! $# -eq 1 ]
then
    echo "\e[31m[!] Usage./auto.sh <target>\e[0m"
    exit 1
fi

target=$1
clear

echo "\e[32m
 #     #               ######                       
 #  #  # ###### #####  #     # ######   ##    ####  
 #  #  # #      #    # #     # #       #  #  #      
 #  #  # #####  #####  ######  #####  #    #  ####  
 #  #  # #      #    # #       #      ######      # 
 #  #  # #      #    # #       #      #    # #    # 
  ## ##  ###### #####  #       ###### #    #  ####  
\e[0m
"

echo "\e[32m[+] Target: $target\e[0m"
echo
echo "\e[32m[+] Scanning will begin\e[0m"
if (sleep 1; echo "y") | python3 /webpeas/CMSeeK/cmseek.py -v -u $target --random-agent | grep -q "Detection failed"; then
  echo "\e[31m[!] CMS is not detected\e[0m"
else
  cms_name=$(echo "y" | python3 /webpeas/CMSeeK/cmseek.py -v -u "$target" --random-agent | grep "CMS:" | awk '{print $2}')
  echo "\e[32m[+] CMS detected: $cms_name\e[0m"
fi
echo
echo "\e[32m[+] Endpoint Enumeration\e[0m"
echo "$target"
dirsearch -u "$target" -x 300-302,303-399,400-499,500-509 -q -o /webpeas/list.txt | awk '(NR > 1)'
echo
if cat /webpeas/list.txt | grep -q -e "/node/7" -e "/node" -e "/admin/content/" -e "/admin/content/comment" -e "/user/login" -e "/user/3"; then
    echo "\e[32m[+] Drupal Scanning\e[0m"
    droopescan scan drupal -u "$target/node" --random-agent | awk '(NR > 14)' || droopescan scan drupal -u "$target/user/login" --random-agent | awk '(NR > 14)'
elif [ "$cms_name" = "\033[1m\033[32mDrupal\033[0m" ]; then
    echo "\e[32m[+] Drupal Scanning\e[0m"
    droopescan scan drupal -u "$target" --random-agent | awk '(NR > 14)'
fi

if cat /webpeas/list.txt | grep -q -e "/administrator" -e "/Joomla" -e "/joomla"; then
    echo "\e[32m[+] joomla Scanning\e[0m"
    perl /webpeas/joomscan/joomscan.pl --url "$target/administrator" --random-agent | awk '(NR > 14)' || perl /webpeas/joomscan/joomscan.pl --url "$target/administrator" --random-agent | awk '(NR > 14)' || perl /webpeas/joomscan/joomscan.pl --url "$target/administrator" --random-agent | awk '(NR > 14)' ||     perl /webpeas/joomscan/joomscan.pl --url "$target/joomla" --random-agent | awk '(NR > 14)'
elif [ "$cms_name" = "\033[1m\033[32mJoomla\033[0m" ]; then
    echo "\e[32m[+] joomla Scanning\e[0m"
    perl /webpeas/joomscan/joomscan.pl --url "$target"--random-agent | awk '(NR > 14)'
fi

if cat /webpeas/list.txt | grep -q -e "/wordpress"; then
    echo "\e[32m[+] Wordpress Scanning\e[0m"²
    wpscan --url "$target/wordpress" -e vp,vt,u --random-user-agent --no-banner | awk '(NR > 4)' | head -n -10
elif [ "$cms_name" = "\033[1m\033[32mWordpress\033[0m" ]; then
    echo "\e[32m[+] Wordpress Scanning\e[0m"
    wpscan --url "$target" -e vp,vt,u --random-user-agent --no-banner | awk '(NR > 4)' | head -n -10
fi
echo
echo "\e[32m[+] Subdomain Enumeration\e[0m"
echo $target | subfinder -silent | httpx -silent | httprobe > /webpeas/sub_enum.txt
cat /webpeas/sub_enum.txt
echo
echo "\e[32m[+] HTTP Subdomains\e[0m"
cat /webpeas/sub_enum.txt | grep -E "http:" | httprobe | sed 's/^/\e[32m[+]\e[0m /' 
echo
echo "\e[32m[+] HTTPS Subdomains: \e[0m"
cat /webpeas/sub_enum.txt | grep -E "https" | httprobe | sed 's/^/\e[32m[+]\e[0m /'
echo
if cat /webpeas/sub_enum.txt | grep -E -e "aws" -e ".cloud" -e "-dev" -e "s3" -e "s2" -e "aws" -e "amazonaws.com" | httprobe -c 50; then
    echo "\e[32m[+] S3 Buckets: \e[0m"
    cat /webpeas/sub_enum.txt | grep -E -e "aws" -e ".cloud" -e "-dev" -e "s3" -e "s2" -e "aws" -e "amazonaws.com" | httprobe -c 50 > /webpeas/buckets.txt
    echo
    echo "\e[32m[+] S3 Scanning: \e[0m"
    nohup s3scanner -bucket-file buckets.txt -o dump.txt | awk '(NR > 2)' > /dev/null 2>&1&
    echo "\e[31m[!] it will take some time \e[0m"
else
    echo "\e[32m[!] There's no S3 Buckets \e[0m"
fi
echo
echo "\e[32m[+] Subdomain Endpoint Enumeration \e[0m"
dirsearch -l /webpeas/sub_enum.txt -x 400-499,500-509 -q -o /webpeas/sub-list-enum.txt | awk '(NR > 1)'
echo
cat -s /webpeas/sub_enum.txt /webpeas/sub-list-enum.txt /webpeas/list.txt | httprobe -c 50 > /webpeas/domain.txt
echo "\e[32m[+] Vulnearability Scanning \e[0m"
nuclei -l /webpeas/domain.txt
echo 
echo "\e[32m[+] GraphQL Discovery \e[0m"
python3 graph.py domain.txt
echo
echo "\e[32m[+] Wayback URLs \e[0m"
cat /webpeas/domain.txt | waybackurls > /webpeas/known_urls.txt
echo
echo "\e[32m Bye \e[0m"