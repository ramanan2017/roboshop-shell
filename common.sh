nodejs(){
  log=/tmp/roboshop.log

  echo -e "\e[36m >>>>>>>>>> Create ${component} Service <<<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Create MongoDB Repo <<<<<<<<<<\e[0m"
  cp  mongo.repo /etc/yum.repos.d/mongo.repo &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Install NodeJS Repos <<<<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Install NodeJS <<<<<<<<<<\e[0m"
  yum install nodejs -y &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Create Application ${component}<<<<<<<<<<\e[0m"
  ${component}add roboshop &>> ${log}

  rm -rf /app &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m"
  mkdir /app &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Download Application Content <<<<<<<<<<\e[0m"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Extract Application Content <<<<<<<<<<\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>> ${log}
  cd /app

  echo -e "\e[36m >>>>>>>>>>Download Nodejs Dependencies <<<<<<<<<<\e[0m"
  npm install &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Start Service <<<<<<<<<<\e[0m"
  systemctl daemon-reload

  echo -e "\e[36m >>>>>>>>>> Download MongoDB <<<<<<<<<<\e[0m"
  yum install mongodb-org-shell -y &>> ${log}

  echo -e "\e[36m >>>>>>>>>> Load Catalogue Schema <<<<<<<<<<\e[0m"
  mongo --host  mongodb.ramdevops.co.uk </app/schema/${component}.js

  echo -e "\e[36m >>>>>>>>>> start services <<<<<<<<<<\e[0m"
  systemctl enable ${component}
  systemctl restart ${component}
}
