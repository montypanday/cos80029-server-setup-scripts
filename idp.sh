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
sudo apt install maven
mvn -pl custom-wordpress-federation -am clean install
cd custom-wordpress-federation
sudo mv /target/custom-wordpress-federation-1.0.0.0-SNAPSHOT.jar /opt/keycloak-17.0.1/providers

cd /opt/keycloak-17.0.1
bin/kc.sh build
sudo bin/kc.sh start-dev --hostname idp.com

cd /bin
kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin
kcadm.sh create realms -s realm=entrustict -s enabled=true -o
kcadm.sh create clients -r entrustict -s clientId=http://172.20.200.2/wp-content/plugins/miniorange-saml-20-single-sign-on/ -s enabled=true
kcadm.sh create clients -r entrustict -s clientId=http://172.20.200.3/wp-content/plugins/miniorange-saml-20-single-sign-on/ -s enabled=true