cp mongo.repo  /etc/yum.repos.d/mongo.repo
yum install mongodb-org -y
#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf
systemctl enable mongod
systemctl restart mongod
