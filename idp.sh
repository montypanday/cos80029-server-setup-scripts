sudo apt update
sudo apt install default-jdk

cd /opt
sudo wget https://github.com/keycloak/keycloak/releases/download/17.0.1/keycloak-17.0.1.tar.gz
sudo tar -xvzf keycloak-17.0.1.tar.gz

export KEYCLOAK_ADMIN_PASSWORD="admin"
export KEYCLOAK_ADMIN="admin"

cd ~
git clone https://github.com/MBKillall5/wpsso.git

cd wpsso
cd wp-federation
mvn -pl custom-wordpress-federation -am clean install

sudo cp /home/student/wpsso/wp-federation/custom-wordpress-federation/target/custom-wordpress-federation-1.0.0.0.jar /opt/keycloak-17.0.0/providers

cd /opt/keycloak-17.0.1
bin/kc.sh build
sudo bin/kc.sh start-dev --hostname idp.com