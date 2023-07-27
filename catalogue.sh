echo -e "\e[36m>>>>>>>> Create Catalogue Service <<<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service

echo -e "\e[36m >>>>>>>> Create MongoDb Repo <<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo -e "\e[36m >>>>>>>>> Install NodeJs repos <<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo -e "\e[36m>>>>>>>>>>> Install Nodejs <<<<<<<<<<\e[0m"
yum install nodejs -y

echo -e "\e[36m >>>>>>>>>>> Create Application User <<<<<<<<<<\e[0m"
useradd roboshop

eco -e "\e[36m >>>>>>>>>>>remove old directory<<<<<<<<<<<\e[0m"
rm -rf /app

echo -e "\e[36m >>>>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m"
mkdir /app

echo -e "\e[36m >>>>>>>>>>>> Download Application Content <<<<<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip

echo -e "\e[36m >>>>>>>>>>> Extract Application Content <<<<<<<<<<<\e[0m"
cd /app
unzip /tmp/catalogue.zip
cd /app

echo -e "\e[36m >>>>>>>>>> Download NodeJs Dependencies <<<<<<<<<<<<\e[0m"
npm install

echo -e "\e[36m >>>>>>>>>>> Install Mongo Client <<<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y

echo -e "\e[36m >>>>>>>>>>>> Load Catalogue Schema <<<<<<<<<<\e[0m"
mongo --host  mongodb.ramdevops.co.uk </app/schema/catalogue.js

echo -e"\e[36m >>>>>>>>>>>>> start services <<<<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
