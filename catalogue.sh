log=/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Create Catalogue Service <<<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service &>> ${log}

echo -e "\e[36m >>>>>>>> Create MongoDb Repo <<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> ${log}

echo -e "\e[36m >>>>>>>>> Install NodeJs repos <<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${log}

echo -e "\e[36m>>>>>>>>>>> Install Nodejs <<<<<<<<<<\e[0m"
yum install nodejs -y &>> ${log}

echo -e "\e[36m >>>>>>>>>>> Create Application User <<<<<<<<<<\e[0m"
useradd roboshop &>> ${log}

echo -e "\e[36m >>>>>>>>>>>remove old directory<<<<<<<<<<<\e[0m"
rm -rf /app &>> ${log}

echo -e "\e[36m >>>>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m"
mkdir /app &>> ${log}

echo -e "\e[36m >>>>>>>>>>>> Download Application Content <<<<<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> ${log}

echo -e "\e[36m >>>>>>>>>>> Extract Application Content <<<<<<<<<<<\e[0m"
cd /app
unzip /tmp/catalogue.zip  &>> ${log}
cd /app

echo -e "\e[36m >>>>>>>>>> Download NodeJs Dependencies <<<<<<<<<<<<\e[0m"
npm install &>> ${log}

echo -e "\e[36m >>>>>>>>>>> Install Mongo Client <<<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y  &>> ${log}

echo -e "\e[36m >>>>>>>>>>>> Load Catalogue Schema <<<<<<<<<<\e[0m"
mongo --host  mongodb.ramdevops.co.uk </app/schema/catalogue.js  &>> ${log}

echo -e "\e[36m >>>>>>>>>>>>> start services <<<<<<<<<<\e[0m"  | tee -a /tmp/roboshop.log
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
