log=/tmp/roboshop.log
func_exit_status(){
  if [ $? -eq 0 ]
  then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi
}

func_apppreq(){
    echo -e "\e[36m >>>>>>>>>> Create ${component} Service <<<<<<<<<<\e[0m"
    cp ${component}.service /etc/systemd/system/${component}.service &>> ${log}
    func_exit_status

    echo -e "\e[36m >>>>>>>>>> Create Application ${component}<<<<<<<<<<\e[0m"
    id roboshop &>> ${log}
    if [ $? -ne 0 ]
    then
      useradd roboshop &>> ${log}
    fi

    func_exit_status

    echo -e "\e[36m >>>>>>>>>> Cleanup Exsisting Application content<<<<<<<<<<\e[0m"
    rm -rf /app &>> ${log}
    func_exit_status

    echo -e "\e[36m >>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m"
    mkdir /app &>> ${log}
    func_exit_status

    echo -e "\e[36m >>>>>>>>>> Download Application Content <<<<<<<<<<\e[0m"
    curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}
    func_exit_status

    echo -e "\e[36m >>>>>>>>>> Extract Application Content <<<<<<<<<<\e[0m"
    cd /app
    unzip /tmp/${component}.zip &>> ${log}
    cd /app
    func_exit_status

}

func_systemd(){
    echo -e "\e[36m >>>>>>>>>> start ${component} services <<<<<<<<<<\e[0m"
    systemctl daemon-reload &>> ${log}
    systemctl enable ${component}
    systemctl restart ${component}
    echo -e "\e[36m >>>>>>>>>> remove log file <<<<<<<<<<\e[0m"
    rm -rf ${log}
    func_exit_status
}

func_schema_setup(){
    if [ "${schema_type}" == "mongodb" ]
    then
      echo -e "\e[36m >>>>>>>>>> Download MongoDB <<<<<<<<<<\e[0m"
      yum install mongodb-org-shell -y &>> ${log}
      func_exit_status

      echo -e "\e[36m >>>>>>>>>> Load Catalogue Schema <<<<<<<<<<\e[0m"
      mongo --host  mongodb.ramdevops.co.uk </app/schema/${component}.js  &>> ${log}
      func_exit_status
    fi

    if [ "${schema_type}" == "mysql" ]
    then
        echo -e "\e[36m >>>>>>>>>> Install MySql Client <<<<<<<<<<\e[0m"
        yum install mysql -y &>> ${log}
        func_exit_status

        echo -e "\e[36m >>>>>>>>>> Load Schema <<<<<<<<<<\e[0m"
        mysql -h mysql.ramdevops.co.uk -uroot -pRoboShop@1 < /app/schema/${component}.sql &>> ${log}
        func_exit_status
    fi
  }

func_nodejs(){
  log=/tmp/roboshop.log

  echo -e "\e[36m >>>>>>>>>> Create ${component} Service <<<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>> ${log}
  func_exit_status

  echo -e "\e[36m >>>>>>>>>> Create MongoDB Repo <<<<<<<<<<\e[0m"
  cp  mongo.repo /etc/yum.repos.d/mongo.repo &>> ${log}
  func_exit_status

  echo -e "\e[36m >>>>>>>>>> Install NodeJS Repos <<<<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${log}
  func_exit_status

  echo -e "\e[36m >>>>>>>>>> Install NodeJS <<<<<<<<<<\e[0m"
  yum install nodejs -y &>> ${log}
  func_exit_status

  func_apppreq

  echo -e "\e[36m >>>>>>>>>>Download Nodejs Dependencies <<<<<<<<<<\e[0m"
  npm install &>> ${log}

  func_schema_setup

  func_systemd
}

func_java(){

  echo -e "\e[36m >>>>>>>>>> Install Maven <<<<<<<<<<\e[0m"
  yum install maven -y &>> ${log}
  func_exit_status

  func_apppreq

  echo -e "\e[36m >>>>>>>>>> Build ${component}  Service <<<<<<<<<<\e[0m"
  mvn clean package &>> ${log}
  mv target/${component}-1.0.jar ${component}.jar &>> ${log}
  func_exit_statusfunc_exit_status

  func_schema_setup

  func_systemd

}

func_python(){
  echo -e "\e[36m >>>>>>>>>> Build ${component}  Service <<<<<<<<<<\e[0m"
  yum install python36 gcc python3-devel -y &>> ${log}
  func_exit_status

  func_apppreq

  echo -e "\e[36m >>>>>>>>>> Install ${component}  Service <<<<<<<<<<\e[0m"
  pip3.6 install -r requirements.txt &>> ${log}
  func_exit_status

  func_systemd

}
func_go(){
  echo -e "\e[36m >>>>>>>>>> Install ${component}  Service <<<<<<<<<<\e[0m"
  yum install golang -y &>> ${log}
  func_exit_status

  func_apppreq

  echo -e "\e[36m >>>>>>>>>> Build ${component}  Service <<<<<<<<<<\e[0m"
  go mod init dispatch &>> ${log}
  go get &>> ${log}
  go build &>> ${log}
  func_exit_status

  func_systemd
}